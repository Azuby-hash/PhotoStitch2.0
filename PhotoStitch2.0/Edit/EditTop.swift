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
    // Non-Pro users get a limited number of free successful saves/shares; afterwards it's Pro-gated.
    @AppStorage("b2e5d47f19c8a306") var freeExportCount = 0
    @State var url: URL?
    @State var progress = 0.0
    
    let geometry: GeometryProxy
    
    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                GlassContainer {
                    HStack(spacing: 12) {
                        Button {
                            homeUpdater.showEdit = false
                        } label: {
                            Image(editUpdater.shareVer ? "xmark" : "chevron.left")
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
                
                if editUpdater.shareVer {
                    Text("Memory limits cap sharing at 8 images.\nOpen the app for unlimited selections.")
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color._black)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color._yellow)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .padding(.horizontal, 16)
                        .transition(.blurReplace.combined(with: .opacity))
                        .allowsHitTesting(false)
                        .zIndex(1000)
                }
            }
            .padding(.horizontal, 16)
            .align(edge: .top, constant: 0)
            
            if showSave {
                save
            }
        }
        .padding(.top, editUpdater.shareVer ? 20 : 0)
        .animation(.smooth(duration: ANIM_DURATION * 2), value: showSave)
        .animation(.smooth(duration: ANIM_DURATION), value: task)
        .animation(.smooth(duration: ANIM_DURATION), value: saveMode)
        .animation(.smooth(duration: ANIM_DURATION), value: editUpdater.sortUpdater?.selectionMode)
        
    }
    
    @ViewBuilder
    var save: some View {
        let saveMode = editUpdater.shareVer ? .jpeg : self.saveMode
        let saveModeBinding = Binding(
            get: { saveMode },
            set: { self.saveMode = $0 }
        )
        
        // Dimmed background overlay dismiss panel
        Color.black.opacity(0.15)
            .ignoresSafeArea()
            .padding(.top, -100)
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
                    Button {
                        if blockedByProGate() { return }

                        share(url)
                    } label: {
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
                            if blockedByProGate() { return }

                            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                                if status == .authorized || status == .limited {
                                    PHPhotoLibrary.shared().performChanges({
                                        PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)
                                    }) { success, err in
                                        DispatchQueue.main.async {
                                            if success {
                                                markFreeExportUsed()
                                            }

                                            if status == .denied {
                                                showAlert(title: "Saved", message: "Image successfully saved to Library.", actions: [
                                                    UIAlertAction(title: String(localized: "OK"), style: .default)
                                                ])
                                            } else {
                                                let assets = editUpdater.items.compactMap({ $0.asset })
                                                
                                                if homeUpdater.removeOriginals == .ask {
                                                    showAlert(title: "Saved", message: "Image successfully saved to Library.", actions: [
                                                        UIAlertAction(title: String(localized: "Delete Original Photos"), style: .destructive, handler: { _ in
                                                            PHPhotoLibrary.shared().performChanges {
                                                                PHAssetChangeRequest.deleteAssets(assets as NSFastEnumeration)
                                                            } completionHandler: { success, _ in
                                                                if success {
                                                                    homeUpdater.showEdit = false
                                                                }
                                                            }
                                                        }),
                                                        UIAlertAction(title: String(localized: "Keep Original Photos"), style: .default)
                                                    ])
                                                }
                                                
                                                if homeUpdater.removeOriginals == .always {
                                                    showAlert(title: "Saved", message: "Image successfully saved to Library.", actions: [
                                                        UIAlertAction(title: String(localized: "OK"), style: .default, handler: { _ in
                                                            PHPhotoLibrary.shared().performChanges {
                                                                PHAssetChangeRequest.deleteAssets(assets as NSFastEnumeration)
                                                            } completionHandler: { success, _ in
                                                                if success {
                                                                    homeUpdater.showEdit = false
                                                                }
                                                            }
                                                        })
                                                    ])
                                                }
                                                
                                                if homeUpdater.removeOriginals == .never {
                                                    showAlert(title: "Saved", message: "Image successfully saved to Library.", actions: [
                                                        UIAlertAction(title: String(localized: "OK"), style: .default)
                                                    ])
                                                }
                                            }
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
                        .modifier(MainGlass(shape: .capsule, type: .color(._background.opacity(0.5))))
                        .tint(Color._blackVert)
                    }
                    
                    if !editUpdater.shareVer {
                        VStack(spacing: 12) {
                            SegmentView(selected: saveModeBinding, items: Mode.allCases.map({ mode in
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
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                .opacity(task != nil ? 0.3 : 1)
                .disabled(task != nil)
                .modifier(MainGlass(shape: RoundedRectangle(cornerRadius: 38), type: .clear))
                
                Button {
                    export(saveMode: saveMode)
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
        .align(edge: .bottom, constant: 0)
        .padding(.horizontal, 16)
        .frame(maxWidth: 450)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    private func export(saveMode: Mode) {
        if task == nil {
            task = Task {
                do {
                    let type: Pipeline.ExportType
                    let url: URL
                    
                    if editUpdater.shareVer {
                        type = .small
                        url = FileManager.tempUrl(name: "\(UUID().uuidString).jpeg")
                    } else {
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
                    }
                    
                    try await editUpdater.export(type, progress: { pro in
                        progress = pro
                    }).write(to: url)
                    
                    self.url = url
                } catch {
                    print(error)

                    if !(error is CancellationError) {
                        editUpdater.warningAlert("Failed to export")
                    }
                }

                task = nil
            }
        }
    }
    
    // The free save/share credits are only spent by non-Pro users; Pro is never gated.
    // The share extension has no Pro concept, so the gate is disabled there.
    private var exportRequiresPro: Bool {
        #if MAIN_APP
        return !StoreKitManager.shared.isPro && freeExportCount >= FREE_EXPORT_LIMIT
        #else
        return false
        #endif
    }

    // Returns true when the action is blocked (non-Pro user who already spent
    // their free saves/shares) and surfaces the subscription upsell.
    private func blockedByProGate() -> Bool {
        guard exportRequiresPro else { return false }

        #if MAIN_APP
        homeUpdater.openSubscription(.immediate)
        #endif

        url = nil
        showSave = false
        return true
    }

    private func markFreeExportUsed() {
        #if MAIN_APP
        if !StoreKitManager.shared.isPro {
            freeExportCount += 1
        }
        #endif
    }

    private func share(_ url: URL) {
        let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activity.completionWithItemsHandler = { _, completed, _, _ in
            if completed {
                self.markFreeExportUsed()
            }
        }

        // iPad requires a popover anchor.
        activity.popoverPresentationController?.sourceView = VIEW_CONTROLLER.view
        activity.popoverPresentationController?.sourceRect = CGRect(
            x: VIEW_CONTROLLER.view.bounds.midX,
            y: VIEW_CONTROLLER.view.bounds.maxY,
            width: 0,
            height: 0
        )

        VIEW_CONTROLLER.present(activity, animated: true)
    }

    private func saveFinish() {
        showSave = false
        url = nil
        progress = 0
        
        if editUpdater.shareVer {
            homeUpdater.showEdit = false
        }
    }
    
    private func showAlert(title: String, message: String, actions: [UIAlertAction] = [UIAlertAction(title: String(localized: "OK"), style: .default)]) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: String(localized: String.LocalizationValue(title)), message: String(localized: String.LocalizationValue(message)), preferredStyle: .alert)
            actions.forEach({ alert.addAction($0) })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                VIEW_CONTROLLER.present(alert, animated: true)
            }
        }
    }
}
