//
//  EditCutTool.swift
//  PhotoCut2.0
//
//  Created by Azuby on 5/30/26.
//

import SwiftUI
import Combine

fileprivate let ANIM_ID = "99ff4d39331756d1"

struct EditCutTool: View {
    @Environment(EditUpdater.self) var editUpdater
    
    @State var showMenu = false
    
    @Namespace var namespace
    
    var body: some View {
        HStack(alignment: .bottom) {
            MenuPopover(showMenu: $showMenu, items: [
                .init(icon: Image(editUpdater.clean ? "eye.slash.fill" : "eye.fill"), name: "Scroll Bar", close: false, action: {
                    editUpdater.clean.toggle()
                }),
                .init(icon: Image("trash.square.stack"), name: "Delete All", action: {
                    editUpdater.cutUpdater?.deleteAll.send()
                }),
                .init(icon: Image(editUpdater.cutUpdater?.mode == .pair ? "scissors.180" : "rectangle.dashed.badge.minus"), name: editUpdater.cutUpdater?.mode == .pair ? "To Cut" : "To Area", action: {
                    editUpdater.cutUpdater?.setMode(editUpdater.cutUpdater?.mode == .pair ? .single: .pair)
                })
            ]) {
                HStack {
                    Image("rectangle.grid.1x2.fill.badge.ellipsis")
                    Text("Options")
                }
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.primary)
                .padding(.horizontal, 20)
                .frame(width: 150, height: 60)
                .modifier(MainGlass(shape: .capsule, type: .clear))
            }
            
            Button {
                editUpdater.tab = .stitch
            } label: {
                HStack {
                    Image("rectangle.arrowtriangle.2.inward")
                    Text("Stitch")
                }
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.primary)
                .padding(.horizontal, 20)
                .frame(height: 60)
                .modifier(MainGlass(shape: .capsule, type: .clear))
            }
        }
        .align(edge: .bottom, constant: 0)
        .onReceive(editUpdater.tapOutside, perform: { _ in
            withAnimation(.smooth(duration: ANIM_DURATION)) {
                showMenu = false
            }
        })
        .animation(.smooth(duration: ANIM_DURATION), value: editUpdater.cutUpdater?.mode)
        .onAppear {
            editUpdater.cutUpdater = EditCutUpdater()
            editUpdater.cutUpdater?.context = editUpdater.editGallery.context
        }
        .onDisappear {
            editUpdater.cutUpdater = nil
        }
    }
}

@Observable class EditCutUpdater {
    @ObservationIgnored var context: EditGallery.Context?
    
    private(set) var constraints: [NSLayoutConstraint] = []
    private(set) var mode: SplitMode = SPLIT_MODE
    
    let deleteAll = PassthroughSubject<Void, Never>()
    
    deinit {
        constraints.forEach({ $0.isActive = false })
    }
    
    func setMode(_ mode: SplitMode) {
        self.mode = mode
        SPLIT_MODE = mode
    }
    
    func setConstraints(_ constraints: [NSLayoutConstraint]) {
        let currConstraints = self.constraints
        constraints.forEach({ NSLayoutConstraint.activate([$0]) })
        removeCutConstraints(currConstraints)
        self.constraints = constraints
    }
    
    private func removeCutConstraints(_ constraints: [NSLayoutConstraint]? = nil) {
        let constraints = constraints ?? self.constraints
        constraints.forEach({ $0.isActive = false })
        self.constraints.removeAll(where: { constraints.contains($0) })
    }
    
    func applyCuts(_ rects: [CGRect]) async throws {
        guard let editUpdater = context?.coordinator.content?.editUpdater,
              let stackView = context?.coordinator.stackView
        else { throw MainError.error("No EditUpdater found") }
        
        var cutRects: [StitchItem: CGRect] = [:]
        
        for rect in rects {
            let isVer = editUpdater.axis == .vertical
            let cutNorRect = rect
            let cutFrame = cutNorRect.insetBy(dx: isVer ? -1 : 0, dy: isVer ? 0 : -1) * stackView.bounds.size
            
            for itemView in (stackView.arrangedSubviews as? [EditItem] ?? []) {
                guard let item = itemView.item else { continue }
                
                let fullItemFrame = itemView.imageView.convert(itemView.imageView.bounds, to: stackView)
                
                if cutFrame.intersects(itemView.frame) {
                    cutRects[item] = (cutFrame.intersection(itemView.frame) - fullItemFrame.origin) / fullItemFrame.size
                }
            }
        }
        
        try await processCut(cutRects)
    }
    
    private func processCut(_ norRects: [StitchItem: CGRect]) async throws {
        guard let editUpdater = context?.coordinator.content?.editUpdater else {
            throw MainError.error("No EditUpdater found")
        }
        
        var resultItems: [StitchItem] = []
        
        try editUpdater.items.forEach { item in
            guard let norRect = norRects[item] else {
                resultItems.append(item)
                return
            }
            
            let currRect = item.process.rect
            
            // 2. Snap the removal area to the edges to avoid slivers
            let snappedRemove = snapRect(norRect, to: currRect, delta: 0.02)
            
            // 3. Define the placeholder area (the intersection)
            let holeRect = currRect.intersection(snappedRemove)
            
            if !holeRect.isNull && holeRect.width > 0 && holeRect.height > 0 {
                var pieceItems: [StitchItem] = []
                // 4. Create Image Fragments using copy()
                let fragmentRects = calculateRemaining(base: currRect, hole: holeRect)
                for fragRect in fragmentRects {
                    let fragmentItem = item.copy() // Preservation of original state
                    fragmentItem.process.setRect(fragRect)
                    pieceItems.append(fragmentItem)
                }
                let placeholder = try StitchItem(asset: item.asset, size: item.size, image: EMPTY_DATA, clean: EMPTY_DATA, process: StitchProcess(rect: holeRect))
                pieceItems.append(placeholder)
                
                let sortedPieces = pieceItems.sorted { (a, b) -> Bool in
                    let rectA = a.process.rect
                    let rectB = b.process.rect
                    if abs(rectA.minY - rectB.minY) > 0.0001 {
                        return rectA.minY < rectB.minY
                    }
                    return rectA.minX < rectB.minX
                }
                
                pieceItems.first?.id = item.id
                
                resultItems.append(contentsOf: sortedPieces)
            } else {
                resultItems.append(item)
            }
        }
        
        let resultItemsFilter = resultItems.filter({ $0.image != (try? EMPTY_DATA) })
        
        if resultItemsFilter.count > MAX_SELECTION {
            throw MainError.error("Exceed max items")
        }
        
        editUpdater.anim = false
        editUpdater.items = resultItems
        
        await withCheckedContinuation { continuation in DispatchQueue.main.async { continuation.resume() } }
        
        editUpdater.anim = true
        editUpdater.items = resultItemsFilter
    }

    private func snapRect(_ remove: CGRect, to base: CGRect, delta: CGFloat) -> CGRect {
        var rect = remove
        if abs(remove.minX - base.minX) < delta { rect.origin.x = base.minX }
        if abs(remove.maxX - base.maxX) < delta { rect.size.width = base.maxX - rect.origin.x }
        if abs(remove.minY - base.minY) < delta { rect.origin.y = base.minY }
        if abs(remove.maxY - base.maxY) < delta { rect.size.height = base.maxY - rect.origin.y }
        return rect
    }

    private func calculateRemaining(base: CGRect, hole: CGRect) -> [CGRect] {
        var rects: [CGRect] = []
        let eps: CGFloat = 0.0001
        
        // Vertical segments
        if hole.minY > base.minY + eps {
            rects.append(CGRect(x: base.minX, y: base.minY, width: base.width, height: hole.minY - base.minY))
        }
        if hole.maxY < base.maxY - eps {
            rects.append(CGRect(x: base.minX, y: hole.maxY, width: base.width, height: base.maxY - hole.maxY))
        }
        // Horizontal segments (middle row)
        if hole.minX > base.minX + eps {
            rects.append(CGRect(x: base.minX, y: hole.minY, width: hole.minX - base.minX, height: hole.height))
        }
        if hole.maxX < base.maxX - eps {
            rects.append(CGRect(x: hole.maxX, y: hole.minY, width: base.maxX - hole.maxX, height: hole.height))
        }
        return rects
    }
}
