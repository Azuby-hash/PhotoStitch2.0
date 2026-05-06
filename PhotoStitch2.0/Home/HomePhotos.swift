//
//  HomePhotos.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 5/5/26.
//

import SwiftUI
import Photos
import PhotosUI

struct HomePhotos: View {
    @Environment(HomeUpdater.self) var updater: HomeUpdater
    
    var body: some View {
        GeometryReader { geometry in
            let num = ceil((geometry.size.width - 32 + 16) / 160)
            
            let assets = updater.album?.assets.filter({
                if updater.photofilter == .images {
                    return $0.mediaType == .image
                }
                
                if updater.photofilter == .videos {
                    return $0.mediaType == .video
                }
                
                return true
            })
            
            ScrollView(showsIndicators: false) {
                if let assets = assets, !isPreview {
                    LazyWFVStack(geometry: geometry, items: assets.map({ asset in
                        return LazyWFVItem(id: asset.localIdentifier, size: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), content: {
                            Button {
                                updater.selecteds.append(asset)
                            } label: {
                                GeometryReader { geometry in
                                    HomePhoto(asset: asset)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .modifier(MainGlass(shape: RoundedRectangle(cornerRadius: 16), type: .clear, interactive: updater.showMenu == .none))
                                }
                            }
                        })
                    }), colWidth: geometry.size.width - 32, columns: Int(num), spacing: 16)
                    .padding(.top, IOS26 ? 0 : 44)
                    .padding(.bottom, IOS26 ? 0 : 60)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 32)
                } else {
                    Color.clear
                }
            }
            .animation(.easeInOut(duration: ANIM_DURATION), value: updater.selecteds)
            .animation(.easeInOut(duration: ANIM_DURATION), value: assets)
            .modifier(HomePhotosEdge())
            .modifier(HomeNoAccess())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color._background)
        }
    }
}

struct HomePhoto: View {
    @State private var image: UIImage?
    
    let asset: PHAsset
    
    var body: some View {
        if let image = image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            Rectangle()
                .fill(Color.clear)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    AssetLibrary.shared.getUIImage(from: asset, size: CGSize(width: 300, height: 300), quality: .opportunistic, resizeMode: .fast) { image in
                        self.image = image
                    }
                }
        }
    }
}

struct HomeNoAccess: ViewModifier {
    @Environment(HomeUpdater.self) var updater: HomeUpdater
    
    func body(content: Content) -> some View {
        let status = AssetLibrary.shared.getCurrentStatus()
        
        if [.authorized, .limited, .notDetermined].contains(status) {
            ZStack {
                content
                
                if status == .limited && updater.selecteds.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        
                        Button {
                            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: VIEW_CONTROLLER)
                        } label: {
                            HStack {
                                Text("Add Photos")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                            }
                            .foregroundStyle(Color._white)
                            .frame(width: 260, height: 60)
                            .modifier(MainGlass(shape: .capsule, type: .color(._primary)))
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
        } else {
            if status == .denied || status == .restricted {
                VStack(spacing: 16) {
                    Text("Please allow access\n to stitch your screenshots.")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(uiColor: .label).opacity(0.75))
                    
                    Button {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                    } label: {
                        HStack {
                            Text("Allow Photos Access")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(Color._white)
                        .frame(width: 260, height: 60)
                        .modifier(MainGlass(shape: .capsule, type: .color(._primary)))
                    }
                }
            }
        }
    }
}

struct HomePhotosEdge: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .safeAreaBar(edge: .top) {
                    Color.white.opacity(0.00001).frame(height: 44)
                }
                .safeAreaBar(edge: .bottom) {
                    Color.white.opacity(0.00001).frame(height: 60)
                }
        } else {
            content.overlay {
                ZStack {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .frame(maxWidth: .infinity, maxHeight: 44 + 44)
                        .mask(LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .white, location: 0),
                                .init(color: .white.opacity(0), location: 1)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                        .align(edge: .top, constant: 0)
                        .ignoresSafeArea()
                    
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .frame(maxWidth: .infinity, maxHeight: 60 + 34)
                        .mask(LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .white, location: 0),
                                .init(color: .white.opacity(0), location: 1)
                            ]),
                            startPoint: .bottom,
                            endPoint: .top
                        ))
                        .align(edge: .bottom, constant: 0)
                        .ignoresSafeArea()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            }
        }
    }
}
