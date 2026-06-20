//
//  EditTop.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 5/30/26.
//

import SwiftUI
import UIKit
import Photos

struct EditTop: View {
    @Environment(HomeUpdater.self) var homeUpdater
    @Environment(EditUpdater.self) var editUpdater
    
    @State var task: Task<Void, Never>?
    
    enum Mode: String, CaseIterable {
        case jpeg = "JPEG"
        case png = "PNG"
        case pdf = "PDF"
    }
    
    @State var showSave = false
    @AppStorage("e9e7f46efc9b8b9d") var saveMode: Mode = .jpeg
    @AppStorage("cd9987b109254938") var quality: Double = 0.8
    @State var url: URL?
    @State var progress = 0.0
    
    let geometry: GeometryProxy
    
    var body: some View {
        ZStack {
            GlassContainer {
                HStack(spacing: 12) {
                    Button {
                        homeUpdater.showEdit = false
                    } label: {
                        Image("chevron.left")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.primary)
                            .frame(width: 44, height: 44)
                            .modifier(MainGlass(shape: .capsule, type: .clear))
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 0) {
                        Button {
                            guard editUpdater.undoRedo.canUndo else { return }
                            
                            editUpdater.block = true
                            
                            Task {
                                do {
                                    try await editUpdater.undoRedo.undo()
                                } catch {
                                    print(error)
                                }
                                
                                editUpdater.block = false
                            }
                        } label: {
                            Image("arrow.uturn.backward")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .frame(width: 44, height: 44)
                        }
                        .disabled(!editUpdater.undoRedo.canUndo)
                        .tint(Color.primary)
                        
                        Button {
                            guard editUpdater.undoRedo.canRedo else { return }
                            
                            editUpdater.block = true
                            
                            Task {
                                do {
                                    try await editUpdater.undoRedo.redo()
                                } catch {
                                    print(error)
                                }
                                
                                editUpdater.block = false
                            }
                        } label: {
                            Image("arrow.uturn.forward")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .frame(width: 44, height: 44)
                        }
                        .disabled(!editUpdater.undoRedo.canRedo)
                        .tint(Color.primary)
                    }
                    .modifier(MainGlass(shape: .capsule, type: .clear))
                    
                    if editUpdater.tab == .sort {
                        let onSelectionMode = editUpdater.sortUpdater?.selectionMode == true
                        
                        Button {
                            editUpdater.sortUpdater?.selectionMode.toggle()
                        } label: {
                            Text(onSelectionMode ? "Done" : "Select")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundStyle(onSelectionMode ? Color._whiteVert : Color.primary)
                                .padding(.horizontal, 16)
                                .frame(height: 44)
                                .modifier(MainGlass(shape: .capsule, type: onSelectionMode ? .color(._blackVert) : .clear))
                        }
                    } else {
                        Button {
                            showSave = true
                        } label: {
                            Image("square.and.arrow.up.fill")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                        }
                        .frame(width: 44, height: 44)
                        .modifier(MainGlass(shape: .capsule, type: .color(._primary)))
                        .tint(Color.white)
                    }
                }
            }
            .padding(.horizontal, 16)
            .align(edge: .top, constant: 0)
            
            if showSave {
                // Dimmed background overlay dismiss panel
                Color.black.opacity(0.15)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showSave = false
                    }
                    .transition(.opacity)
                
                // The Bottom Sheet
                GlassContainer {
                    if let url = url {
                        VStack(spacing: 20) {
                            HStack {
                                Text("Export Complete")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .padding(.leading, 16)
                                
                                Spacer()
                                
                                Button {
                                    saveFinish()
                                } label: {
                                    Image("xmark")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                }
                                .frame(width: 44, height: 44)
                                .modifier(MainGlass(shape: .capsule, type: .color(._blackVert)))
                                .tint(Color._whiteVert)
                            }
                            
                            VStack {
                                Text("Save your stitched photo to the device gallery\nor share it directly with friends.")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.bottom, 8)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity)
                        .modifier(MainGlass(shape: RoundedRectangle(cornerRadius: 38), type: .clear))
                        
                        HStack {
                            ShareLink(item: url) {
                                HStack {
                                    Image("square.and.arrow.up.fill")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    Text("Share")
                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .modifier(MainGlass(shape: .capsule, type: .clear))
                                .tint(.primary)
                            }
                            
                            if saveMode != .pdf {
                                Button {
                                    if #available(iOS 14, *) {
                                        PHPhotoLibrary.requestAuthorization(for: .addOnly, handler: { status in
                                            if status == .authorized || status == .limited {
                                                PHPhotoLibrary.shared().performChanges({
                                                    PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)
                                                }) { success, err in
                                                    DispatchQueue.main.async {
                                                        editUpdater.warningAlert("Saved to your photo gallery")
                                                        saveFinish()
                                                    }
                                                }
                                            } else {
                                                DispatchQueue.main.async {
                                                    editUpdater.warningAlert("Failed to save")
                                                    saveFinish()
                                                }
                                            }
                                        })
                                    } else {
                                        PHPhotoLibrary.requestAuthorization { status in
                                            if status == .authorized {
                                                PHPhotoLibrary.shared().performChanges({
                                                    PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)
                                                }) { success, err in
                                                    DispatchQueue.main.async {
                                                        editUpdater.warningAlert("Saved to your photo gallery")
                                                        saveFinish()
                                                    }
                                                }
                                            } else {
                                                DispatchQueue.main.async {
                                                    editUpdater.warningAlert("Failed to save")
                                                    saveFinish()
                                                }
                                            }
                                        }
                                    }
                                    
                                    showSave = false
                                } label: {
                                    HStack {
                                        Image("square.and.arrow.up.fill")
                                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        Text("Save")
                                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .modifier(MainGlass(shape: .capsule, type: .color(._primary)))
                                    .tint(.white)
                                }
                            }
                        }
                    } else {
                        VStack(spacing: 20) {
                            HStack {
                                Text("Export Options")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .padding(.leading, 16)
                                
                                Spacer()
                                
                                Button {
                                    showSave = false
                                } label: {
                                    Image("xmark")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                }
                                .frame(width: 44, height: 44)
                                .modifier(MainGlass(shape: .capsule, type: .color(._blackVert)))
                                .tint(Color._whiteVert)
                            }
                            
                            VStack(spacing: 12) {
                                SegmentView(selected: $saveMode, items: Mode.allCases.map({ mode in
                                    SegmentViewItem(id: mode, text: mode.rawValue)
                                }))
                                .frame(maxWidth: .infinity, maxHeight: 60)
                                
                                if saveMode == .jpeg {
                                    Slider(value: $quality, label: { }) {
                                        Text("Quality")
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .padding(.trailing, 8)
                                    } maximumValueLabel: {
                                        Text("\(quality * 100, specifier: "%3.0f")")
                                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                                            .padding(.leading, 8)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(Color.clear.background(.ultraThinMaterial).clipShape(.capsule))
                                    .tint(._primary)
                                }
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity)
                        .opacity(task != nil ? 0.3 : 1)
                        .disabled(task != nil)
                        .modifier(MainGlass(shape: RoundedRectangle(cornerRadius: 38), type: .clear))
                        
                        Button {
                            if task == nil {
                                task = Task {
                                    do {
                                        let type: Pipeline.ExportType
                                        let url: URL
                                        
                                        switch(saveMode) {
                                        case .jpeg:
                                            type = .raw(quality: quality)
                                            url = FileManager.tempUrl(name: "\(UUID().uuidString).jpeg")
                                        case .png:
                                            type = .raw(quality: COMPRESSION_QUALITY)
                                            url = FileManager.tempUrl(name: "\(UUID().uuidString).png")
                                        case .pdf:
                                            type = .pdf
                                            url = FileManager.tempUrl(name: "\(UUID().uuidString).pdf")
                                        }
                                        
                                        try await editUpdater.export(type, progress: { pro in
                                            progress = pro
                                        }).write(to: url)
                                        
                                        self.url = url
                                    } catch {
                                        print(error)
                                    }
                                    
                                    task = nil
                                }
                            }
                        } label: {
                            HStack {
                                if task == nil {
                                    Image("square.and.arrow.up.fill")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    Text("Export Photo")
                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                                } else {
                                    Text("Exporting...")
                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    Spacer()
                                    Text("\(progress * 100, specifier: "%.0f")%")
                                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                                }
                            }
                            .padding(.horizontal, 24)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .modifier(MainGlass(shape: .capsule, type: .color(task == nil ? ._primary : .clear)))
                            .tint(task == nil ? .white : .primary)
                        }
                    }
                }
                .align(edge: .bottom, constant: 16)
                .ignoresSafeArea(edges: .bottom)
                .padding(.horizontal, 16)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.smooth(duration: ANIM_DURATION * 2), value: showSave)
        .animation(.smooth(duration: ANIM_DURATION), value: task)
        .animation(.smooth(duration: ANIM_DURATION), value: saveMode)
        .animation(.smooth(duration: ANIM_DURATION), value: editUpdater.sortUpdater?.selectionMode)
        
    }
    
    private func saveFinish() {
        showSave = false
        url = nil
        progress = 0
    }
}
