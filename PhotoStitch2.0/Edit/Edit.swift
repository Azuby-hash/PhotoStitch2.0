//
//  EditVC.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 5/7/26.
//

import SwiftUI
import Combine

struct Edit: View {
    @State var editUpdater: EditUpdater
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                let safeAreaInsets = geometry.safeAreaInsets
                let bonusInset = getInset(geometry.size)
                let totalInset = EdgeInsets(top: safeAreaInsets.top + bonusInset.top, leading: safeAreaInsets.leading + bonusInset.leading, bottom: safeAreaInsets.bottom + bonusInset.bottom, trailing: safeAreaInsets.trailing + bonusInset.trailing)
                
                EditGallery(edgeInsets: totalInset, baseInsets: bonusInset)
                    .ignoresSafeArea()
                    .modifier(EdgeModifier(top: 44, bottom: 60))
            }
            
            EditTop()
            EditBottom()
            
            if !editUpdater.warningText.isEmpty {
                Text(editUpdater.warningText)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color._background)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 0)
                    .padding(.horizontal, 16)
                    .transition(.blurReplace.combined(with: .opacity))
                    .allowsHitTesting(false)
                    .zIndex(1000)
            }
        }
        .onTapGesture {
            editUpdater.tapOutside.send()
        }
        .environment(editUpdater)
        .animation(.smooth(duration: ANIM_DURATION), value: editUpdater.tab)
        .animation(.smooth(duration: ANIM_DURATION), value: editUpdater.warningText)
    }
    
    func getInset(_ size: CGSize) -> EdgeInsets {
        let hozMultiple = editUpdater.tab == .sort ? (isIpad ? 0.4 : 0.3) : (isIpad ? 0.3 : 0.2)
        let topMultiple = editUpdater.tab == .sort ? (isIpad ? 0.4 : 0.3) : (isIpad ? 0.2 : 0.1)
        let bottomMultiple = editUpdater.tab == .sort ? (isIpad ? 0.4 : 0.3) : (isIpad ? 0.3 : 0.2)
        
        let hozInset = editUpdater.axis == .vertical ? size.width * hozMultiple : 48
        let topInset = editUpdater.axis == .horizontal ? size.height * topMultiple : 48
        let bottomInset = editUpdater.axis == .horizontal ? size.height * bottomMultiple : 48
        
        return EdgeInsets(top: topInset + 44, leading: hozInset, bottom: bottomInset + 60, trailing: hozInset)
    }
}

enum EditTab: String, CaseIterable {
    case stitch = "stitch"
    case split = "split"
    case sort = "sort"
    case none = "none"
}

@Observable class EditUpdater {
    var items: [StitchItem]
    var axis: NSLayoutConstraint.Axis
    var clean: Bool = false
    var tab = EditTab.none
    var anim = true
    
    var stitchUpdater: EditStitchUpdater? = .init() // DO NOT SET NIL HERE OR INSIDE WILL NOT UPDATE
    var cutUpdater: EditCutUpdater? = .init() // DO NOT SET NIL HERE OR INSIDE WILL NOT UPDATE
    var sortUpdater: EditSortUpdater? = .init() // DO NOT SET NIL HERE OR INSIDE WILL NOT UPDATE

    let editGallery = EditGalleryModel()
    
    private(set) var warningText = ""
    @ObservationIgnored private var warningTask: Task<Void, Never>?
    
    let tapOutside: PassthroughSubject<Void, Never> = .init()
    
    init(items: [StitchItem], axis: NSLayoutConstraint.Axis) {
        self.items = items
        self.axis = axis
        
        self.stitchUpdater = nil
        self.cutUpdater = nil
        self.sortUpdater = nil
    }
    
    func animIfNeeded(perform: @escaping () -> Void) {
        if anim {
            perform()
        } else {
            UIView.performWithoutAnimation {
                perform()
            }
        }
    }
}

extension EditUpdater {
    func warningAlert(_ string: String) {
        warningTask?.cancel()
        warningText = string
        warningTask = Task {
            try? await Task.sleep(for: .seconds(2))

            if !Task.isCancelled {
                await MainActor.run {
                    warningText = ""
                }
            }
        }
    }
}
