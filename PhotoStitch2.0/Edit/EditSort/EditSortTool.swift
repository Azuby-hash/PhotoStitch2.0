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
            if editUpdater.sortUpdater?.selectionMode == true {
                Button {
                    editUpdater.items.removeAll(where: { editUpdater.sortUpdater?.selectItems.contains($0) == true })
                    editUpdater.sortUpdater?.selectItems.removeAll()
                    editUpdater.sortUpdater?.selectionMode = false
                } label: {
                    HStack {
                        Image("trash")
                        Text("Delete")
                    }
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color._red.opacity(editUpdater.sortUpdater?.selectItems.isEmpty == false ? 1 : 0.3))
                    .padding(.horizontal, 24)
                    .frame(height: 60)
                    .modifier(MainGlass(shape: .capsule, type: .clear))
                }
                .allowsHitTesting(editUpdater.sortUpdater?.selectItems.isEmpty == false)
            } else {
                Button {
                    
                } label: {
                    HStack {
                        Image("rectangle.arrowtriangle.2.top.badge.plus")
                        Text("Head")
                    }
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.primary)
                    .padding(.horizontal, 20)
                    .frame(height: 60)
                    .modifier(MainGlass(shape: .capsule, type: .clear))
                }
                
                Button {
                    
                } label: {
                    HStack {
                        Image("rectangle.arrowtriangle.2.bottom.badge.plus")
                        Text("Tail")
                    }
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.primary)
                    .padding(.horizontal, 20)
                    .frame(height: 60)
                    .modifier(MainGlass(shape: .capsule, type: .clear))
                }
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
    
    var selectItems: [StitchItem] = []
    var selectionMode = false
}
