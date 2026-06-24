//
//  HomePhotos.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 5/5/26.
//

import UIKit
import SwiftUI
import Photos
import PhotosUI

private struct PhotoFrameValue: Equatable {
    let frame: CGRect
    let index: Int
}

private struct PhotoFrameKey: PreferenceKey {
    static var defaultValue: [PHAsset: PhotoFrameValue] = [:]
    static func reduce(value: inout [PHAsset: PhotoFrameValue], nextValue: () -> [PHAsset: PhotoFrameValue]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct HomePhotos: View {
    @Environment(HomeUpdater.self) var homeUpdater: HomeUpdater

    @State private var itemFrames: [PHAsset: PhotoFrameValue] = [:]
    @State private var isDragSelecting = false
    @State private var isCancelled = false
    @State private var beginSelected = [PHAsset]()
    @State private var startLocation: CGPoint = .zero
    
    @GestureState private var isGestureActive = false
    
    var body: some View {
        GeometryReader { geometry in
            let num = ceil((geometry.size.width - 32 + 16) / 160)
            
            let assets = homeUpdater.filterAssets()
            
            ScrollView(showsIndicators: false) {
                if let assets = assets {
                    LazyWFVStack(geometry: geometry, items: assets.enumerated().map({ (assetIndex, asset) in
                        let selected = homeUpdater.selecteds.contains(asset)
                        let index = homeUpdater.selecteds.firstIndex(of: asset) ?? 0
                        
                        return LazyWFVItem(id: asset.localIdentifier, size: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), content: {
                            Button {
                                if selected {
                                    homeUpdater.deselect(asset)
                                } else {
                                    homeUpdater.select(asset)
                                }
                            } label: {
                                GeometryReader { geo in
                                    HomePhoto(asset: asset)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .modifier(MainGlass(shape: RoundedRectangle(cornerRadius: 16), type: .clear, interactive: homeUpdater.showMenu == .none))
                                        .modifier(HomePhotoSelection(selection: selected, number: index + 1))
                                        .preference(key: PhotoFrameKey.self, value: [asset: PhotoFrameValue(frame: geo.frame(in: .global), index: assetIndex)])
                                }
                            }
                        })
                    }), colWidth: geometry.size.width - 32, columns: Int(num), spacing: 16)
                    .padding(.top, IOS26 ? 0 : 44)
                    .padding(.bottom, IOS26 ? 0 : 60)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 32)
                    .animation(.smooth(duration: ANIM_DURATION), value: homeUpdater.selecteds)
                } else {
                    Color.clear
                }
            }
            .scrollDisabled(isDragSelecting)
            .onPreferenceChange(PhotoFrameKey.self) { frames in
                itemFrames = frames
            }
            .simultaneousGesture(
                DragGesture(coordinateSpace: .global)
                    .updating($isGestureActive) { _, state, _ in
                        state = true
                    }
                    .onChanged { value in
                        guard !isCancelled else { return }
                        let dx = abs(value.translation.width)
                        let dy = abs(value.translation.height)

                        if !isDragSelecting {
                            guard dx > dy, dx > 5 else {
                                isCancelled = true
                                return
                            }
                            
                            isDragSelecting = true
                            startLocation = value.startLocation
                            beginSelected = homeUpdater.selecteds
                        } else {
                            guard let firstIndex = itemFrames.first(where: { $0.value.frame.contains(startLocation) })?.value.index else { return }
                            
                            let loc = value.location
                            let selectionRect = CGRect( x: min(startLocation.x, loc.x), y: min(startLocation.y, loc.y), width: abs(loc.x - startLocation.x), height: abs(loc.y - startLocation.y))
                            
                            let newIntersecteds = itemFrames.filter({ selectionRect.intersects($0.value.frame) }).sorted(by: { abs(firstIndex - $0.value.index) < abs(firstIndex - $1.value.index) }).map { $0.key }.filter({ $0.mediaType == .image })
                            
                            var selecteds = beginSelected.compactMap({ selected in
                                homeUpdater.filterAssets()?.first(where: { $0 == selected })
                            })
                            
                            for asset in newIntersecteds {
                                selecteds = selecteds.filter({ $0 != asset })

                                if !beginSelected.contains(asset) {
                                    selecteds.append(asset)
                                }
                            }
                            
                            homeUpdater.setSelect(selecteds)
                        }
                    }
            )
            .onChange(isGestureActive) { active in
                if !active {
                    isDragSelecting = false
                    isCancelled = false
                }
            }
            .animation(.smooth(duration: ANIM_DURATION), value: assets)
            .modifier(EdgeModifier(top: 44, bottom: 60))
            .modifier(HomeNoAccess())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct HomePhoto: View {
    @State private var image: UIImage?
    
    let asset: PHAsset
    
    var body: some View {
        if let image = image {
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                if asset.mediaType == .video {
                    Text(Duration.seconds(asset.duration), format: .time(pattern: .minuteSecond))
                        .foregroundStyle(Color.white)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .align(edge: .trailing, constant: 8)
                        .align(edge: .bottom, constant: 8)
                        .shadow(color: .black, radius: 5, x: 0, y: 0)
                }
            }
        } else {
            Rectangle()
                .fill(.ultraThinMaterial)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    Task {
                        image = try? await preview(from: asset, quality: .opportunistic, resizeMode: .fast)
                    }
                }
        }
    }
    
    @PipelineActor
    func preview(from asset: PHAsset, quality: PHImageRequestOptionsDeliveryMode = .highQualityFormat, resizeMode: PHImageRequestOptionsResizeMode = .fast) async throws -> UIImage {
        
        let size = await CGSize(width: asset.pixelWidth, height: asset.pixelHeight).aspectFill(to: CGSize(width: 300, height: 300))
        
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        
        options.deliveryMode = quality
        options.resizeMode = resizeMode
        options.isNetworkAccessAllowed = true
        options.isSynchronous = true
        
        var image: UIImage?

        manager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options, resultHandler: { (result, _) -> Void in
            image = result
        })
        
        guard let image = image else {
            throw ALError.error("Request image failed")
        }
        
        return image
    }
}

struct HomePhotoSelection: ViewModifier {
    @Environment(HomeUpdater.self) var homeUpdater: HomeUpdater
    
    let selection: Bool
    let number: Int
    
    func body(content: Content) -> some View {
        if selection {
            content
                .overlay(Color._primary.opacity(0.2).clipShape(RoundedRectangle(cornerRadius: 16)).allowsHitTesting(false))
                .overlay {
                    Text("\(number)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(Color._white)
                        .frame(width: 48, height: 48)
                        .modifier(MainGlass(shape: .capsule, type: .color(._primary), interactive: false))
                        .allowsHitTesting(false)
                }
        } else {
            content
        }
    }
}


struct HomeNoAccess: ViewModifier {
    @Environment(HomeUpdater.self) var homeUpdater: HomeUpdater
    
    func body(content: Content) -> some View {
        let status = AssetLibrary.getCurrentStatus()
        
        if [.authorized, .limited, .notDetermined].contains(status) {
            ZStack {
                content
                
                if status == .limited && homeUpdater.selecteds.isEmpty {
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
