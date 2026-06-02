//
//  EditCutTool.swift
//  PhotoCut2.0
//
//  Created by Azuby on 5/30/26.
//

import SwiftUI

struct EditCutTool: View {
    @Environment(EditUpdater.self) var editUpdater
    
    var body: some View {
        HStack {
            Button {
                
            } label: {
                HStack {
                    Image("rectangle.grid.1x2.fill.badge.ellipsis")
                    Text("Actions")
                }
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.primary)
                .padding(.horizontal, 20)
                .frame(height: 60)
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
}
