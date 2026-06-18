//
//  EditStitchTool.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 5/29/26.
//

import SwiftUI
import PhotosUI

struct EditSortTool: View {
    @Environment(EditUpdater.self) var editUpdater
    
    var body: some View {
        @Bindable var editUpdater = editUpdater
        
        let showPhotoPicker = Binding(
            get: { editUpdater.sortUpdater?.showPhotoPicker == true },
            set: { editUpdater.sortUpdater?.showPhotoPicker = $0 }
        )
        
        let photoItem = Binding(
            get: { editUpdater.sortUpdater?.photoItem },
            set: { editUpdater.sortUpdater?.photoItem = $0 }
        )
        
        HStack {
            if editUpdater.sortUpdater?.selectionMode == true {
                let opacity = editUpdater.sortUpdater?.selectItems.isEmpty == false ? 1 : 0.3
                
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
                    .foregroundStyle(Color._white.opacity(opacity))
                    .padding(.horizontal, 24)
                    .frame(height: 60)
                    .modifier(MainGlass(shape: .capsule, type: .color(._red.opacity(opacity))))
                }
                .allowsHitTesting(editUpdater.sortUpdater?.selectItems.isEmpty == false)
                .animation(.smooth(duration: ANIM_DURATION), value: opacity)
            } else {
                Button {
                    editUpdater.sortUpdater?.photoPosition = .before
                    editUpdater.sortUpdater?.showPhotoPicker = true
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
                    editUpdater.sortUpdater?.photoPosition = .after
                    editUpdater.sortUpdater?.showPhotoPicker = true
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
        .onChange(editUpdater.sortUpdater?.selectionMode) { mode in
            if mode != true {
                editUpdater.sortUpdater?.selectItems.removeAll()
            }
        }
        .sheet(isPresented: showPhotoPicker, content: {
            PhotosPicker(selection: photoItem, matching: .images, photoLibrary: .shared()) {
                if let position = editUpdater.sortUpdater?.photoPosition {
                    if case .before = position {
                        Text("Select a photo to add to first of list")
                    }
                    
                    if case .after = position {
                        Text("Select a photo to add to last of list")
                    }
                    
                    if case .mid = position {
                        Text("Select a photo to add to current position of list")
                    }
                    
                    if case .replace = position {
                        Text("Select a photo to replace item")
                    }
                }
            }
            .photosPickerStyle(.inline)
        })
        .onChange(showPhotoPicker.wrappedValue) { _ in
            if showPhotoPicker.wrappedValue { return }
            
            Task {
                do {
                    if let position = editUpdater.sortUpdater?.photoPosition, let data = try await photoItem.wrappedValue.unwrap().loadTransferable(type: Data.self), let image = UIImage(data: data) {
                        let image = PIPELINE.fixImageForOpenCV(image)
                        print(try photoItem.wrappedValue.unwrap())
                        let newItem = try StitchItem(asset: PHAsset.fetchAssets(withLocalIdentifiers: [photoItem.wrappedValue.unwrap().itemIdentifier.unwrap()], options: nil).object(at: 0), size: image.size, image: image.jpegData(), clean: image.processClean(), process: StitchProcess().setup(image: CIImage(image: image).unwrap(), config: Stitch.getConfig(mode: .image)))
                        
                        if case .before = position {
                            editUpdater.items.insert(newItem, at: 0)
                        }
                        
                        if case .after = position {
                            editUpdater.items.insert(newItem, at: editUpdater.items.count)
                        }
                        
                        if case let .mid(item) = position, let index = editUpdater.items.firstIndex(of: item) {
                            editUpdater.items.insert(newItem, at: index + 1)
                        }
                        
                        if case let .replace(item) = position, let index = editUpdater.items.firstIndex(of: item) {
                            newItem.id = editUpdater.items[index].id
                            editUpdater.items[index] = newItem
                        }
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
}

@Observable class EditSortUpdater {
    @ObservationIgnored var context: EditGallery.Context?
    
    var selectItems: [StitchItem] = []
    var selectionMode = false
    
    var photoItem: PhotosPickerItem?
    var photoPosition: SortPosition = .before
    var showPhotoPicker: Bool = false
}

enum SortPosition {
    case before
    case mid(afterItem: StitchItem)
    case after
    case replace(item: StitchItem)
}
