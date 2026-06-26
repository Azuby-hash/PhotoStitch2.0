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

        let photoItems = Binding(
            get: { editUpdater.sortUpdater?.photoItems ?? [] },
            set: { editUpdater.sortUpdater?.photoItems = $0 }
        )
        
        HStack {
            if editUpdater.sortUpdater?.selectionMode == true {
                let opacity = editUpdater.sortUpdater?.selectItems.isEmpty == false ? 1 : 0.3
                
                Button {
                    editUpdater.undoRedoBegin()
                    
                    editUpdater.items.removeAll(where: { editUpdater.sortUpdater?.selectItems.contains($0) == true })
                    editUpdater.sortUpdater?.selectItems.removeAll()
                    editUpdater.sortUpdater?.selectionMode = false
                    
                    editUpdater.undoRedoCommit()
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
                    if MAX_SELECTION - editUpdater.items.count > 0 {
                        editUpdater.sortUpdater?.photoPosition = .before
                        editUpdater.sortUpdater?.showPhotoPicker = true
                    } else {
                        editUpdater.warningAlert("Maximum number of items reached.")
                    }
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
                    if MAX_SELECTION - editUpdater.items.count > 0 {
                        editUpdater.sortUpdater?.photoPosition = .after
                        editUpdater.sortUpdater?.showPhotoPicker = true
                    } else {
                        editUpdater.warningAlert("Maximum number of items reached.")
                    }
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
            let maxSelectionCount: Int? = {
                switch editUpdater.sortUpdater?.photoPosition {
                case .replace:
                    return 1
                default:
                    return MAX_SELECTION - editUpdater.items.count
                }
            }()
            
            PhotosPicker(selection: photoItems, maxSelectionCount: maxSelectionCount, matching: .images, photoLibrary: .shared()) {
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
                editUpdater.undoRedoBegin()
                
                do {
                    if let position = editUpdater.sortUpdater?.photoPosition {
                        let items = try await getItems()

                        if case .before = position {
                            editUpdater.items.insert(contentsOf: items, at: 0)
                        }
                        
                        if case .after = position {
                            editUpdater.items.insert(contentsOf: items, at: editUpdater.items.count)
                        }
                        
                        if case let .mid(item) = position, let index = editUpdater.items.firstIndex(of: item) {
                            editUpdater.items.insert(contentsOf: items, at: index + 1)
                        }
                        
                        if case let .replace(item) = position, let index = editUpdater.items.firstIndex(of: item), let newItem = items.first {
                            newItem.id = editUpdater.items[index].id
                            editUpdater.items[index] = newItem
                        }
                        
                        editUpdater.undoRedoCommit()
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func getItems() async throws -> [StitchItem] {
        guard let sortUpdater = editUpdater.sortUpdater else {
            throw MainError.error("No sort updater")
        }
        
        VIEW_CONTROLLER.startLoading("Loading 0 / \(sortUpdater.photoItems.count) Photos...")
        
        let items = await withTaskGroup(of: Optional<StitchItem>.self) { group in
            var items = [StitchItem]()
            
            for photoItem in sortUpdater.photoItems {
                group.addTask {
                    var item: StitchItem?
                    
                    do {
                        if let data = try await photoItem.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                            let image = await PIPELINE.fixImageForOpenCV(image)
                            item = try await StitchItem(asset: PHAsset.fetchAssets(withLocalIdentifiers: [photoItem.itemIdentifier.unwrap()], options: nil).object(at: 0), size: image.size, image: image.jpegData(), clean: image.processClean(), process: StitchProcess().setup(image: CIImage(image: image).unwrap(), config: Stitch.getConfig(mode: .image)))
                        }
                    } catch {
                        print(error)
                    }
                    
                    return item
                }
            }
            
            for await item in group {
                if let item = item {
                    items.append(item)
                    
                    VIEW_CONTROLLER.startLoading("Loading \(items.count) / \(sortUpdater.photoItems.count) Photos...")
                }
            }
            
            return items.sorted(by: { (item1, item2) in (sortUpdater.photoItems.firstIndex(where: { $0.itemIdentifier == item1.asset?.localIdentifier }) ?? 0) < (sortUpdater.photoItems.firstIndex(where: { $0.itemIdentifier == item2.asset?.localIdentifier }) ?? 0) })
        }
        
        guard !items.isEmpty else {
            throw MainError.error("No Items")
        }
        
        if AUTO_STITCH, items.count >= 2 {
            VIEW_CONTROLLER.startLoading("Auto Stitch...")
            try await PIPELINE.autoStitch(items)
        }
        
        await withCheckedContinuation { continuation in VIEW_CONTROLLER.stopLoading { continuation.resume() } }
        
        sortUpdater.photoItems = []
        
        return items
    }
}

@Observable class EditSortUpdater {
    @ObservationIgnored var context: EditGallery.Context?
    
    var selectItems: [StitchItem] = []
    var selectionMode = false
    
    var photoItems: [PhotosPickerItem] = []
    var photoPosition: SortPosition = .before
    var showPhotoPicker: Bool = false
}

enum SortPosition {
    case before
    case mid(afterItem: StitchItem)
    case after
    case replace(item: StitchItem)
}
