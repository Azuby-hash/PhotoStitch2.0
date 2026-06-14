//
//  EditStitchTool.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 5/29/26.
//

import SwiftUI

struct EditSortTool: View {
    @Environment(EditUpdater.self) var editUpdater
    
    var body: some View {
        HStack {
            if editUpdater.axis == .vertical {
                Button {
                    
                } label: {
                    HStack {
                        Image("rectangle.arrowtriangle.2.top.badge.plus")
                        Text("Top")
                    }
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.primary)
                    .padding(.horizontal, 20)
                    .frame(height: 60)
                    .modifier(MainGlass(shape: .capsule, type: .clear))
                }
            }
            
            Button {
                
            } label: {
                HStack {
                    Image("rectangle.arrowtriangle.2.bottom.badge.plus")
                    Text("Bottom")
                }
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.primary)
                .padding(.horizontal, 20)
                .frame(height: 60)
                .modifier(MainGlass(shape: .capsule, type: .clear))
            }
        }
        .align(edge: .bottom, constant: 0)
        .onAppear {
            editUpdater.sortUpdater = EditSortUpdater()
            editUpdater.sortUpdater?.context = editUpdater.editGallery.context
        }
        .onDisappear {
            editUpdater.sortUpdater = nil
        }
    }
}

@Observable class EditSortUpdater {
    @ObservationIgnored var context: EditGallery.Context?
    
    private(set) var selectItem: StitchItem?
    private(set) var constraints: [NSLayoutConstraint] = []
    private(set) var frames: [(item: StitchItem, rect: CGRect)] = []
    private(set) var translateBefore: CGPoint = .zero
    private(set) var translateAfter: CGPoint = .zero
    
    deinit {
        constraints.forEach({ $0.isActive = false })
    }
    
    func setTranslateBefore(_ translate: CGPoint) {
        translateBefore = translate
    }
    
    func setTranslateAfter(_ translate: CGPoint) {
        translateAfter = translate
    }
    
    func setSelectItem(_ item: StitchItem?) {
        context?.coordinator.content?.editUpdater.items.forEach { item in
            if item.process.rect.height < MIN_REMOVE || item.process.rect.width < MIN_REMOVE {
                context?.coordinator.content?.editUpdater.items = context?.coordinator.content?.editUpdater.items.filter({ $0 != item }) ?? []
            }
        }
        
        selectItem = item
        
        if item == nil {
            removeStitchConstraints()
            
            frames = []
            translateBefore = .zero
            translateAfter = .zero
        } else {
            frames = context?.coordinator.content?.editUpdater.items.map({ ($0, $0.process.rect) }) ?? []
            translateBefore = .zero
            translateAfter = .zero
        }
    }
    
    func setConstraints(_ constraints: [NSLayoutConstraint]) {
        let currConstraints = self.constraints
        constraints.forEach({ NSLayoutConstraint.activate([$0]) })
        removeStitchConstraints(currConstraints)
        self.constraints = constraints
    }
    
    private func removeStitchConstraints(_ constraints: [NSLayoutConstraint]? = nil) {
        let constraints = constraints ?? self.constraints
        constraints.forEach({ $0.isActive = false })
        self.constraints.removeAll(where: { constraints.contains($0) })
    }
}
