//
//  HomeBottom.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 5/3/26.
//

import SwiftUI
import Photos
import Combine

struct HomeBottom: View {
    @Environment(HomeUpdater.self) var homeUpdater
    
    var body: some View {
        GlassContainer {
            if homeUpdater.showMenu == .web { } else if homeUpdater.showMenu == .filters {
                VStack(spacing: 0) {
                    ForEach(getFilterCase(), id: \.self) { filter in
                        Button {
                            homeUpdater.photofilter = filter
                            homeUpdater.showMenu = .none
                        } label: {
                            HStack(spacing: 12) {
                                Image(filter.icon)
                                    .frame(width: 20)
                                Text(filter.title)
                                Spacer()
                                Image("checkmark")
                                    .opacity(homeUpdater.photofilter == filter ? 1 : 0)
                            }
                            .foregroundStyle(Color(uiColor: .label))
                            .frame(height: 40)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .frame(maxWidth: 220)
                .modifier(MainGlass(shape: RoundedRectangle(cornerRadius: 24), type: .clear))
            } else if homeUpdater.selecteds.isEmpty {
                Button {
                    homeUpdater.showMenu = .filters
                } label: {
                    HStack(spacing: 12) {
                        Image(homeUpdater.photofilter.icon)
                            .frame(width: 20)
                        Text(homeUpdater.photofilter.title)
                    }
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(uiColor: .label))
                    .padding(.horizontal, 20)
                    .frame(height: 60)
                    .modifier(MainGlass(shape: .capsule, type: .clear))
                }
            } else {
                Button {
                    Task {
                        do {
                            homeUpdater.items = try await getItems()
                            homeUpdater.axis = .horizontal
                            homeUpdater.showEdit = true
                        } catch {
                            print(error)
                        }
                    }
                } label: {
                    Image(.horizontal)
                        .foregroundStyle(Color(uiColor: .label))
                        .frame(width: 60, height: 60)
                        .modifier(MainGlass(shape: .capsule, type: .clear))
                }
            }
        }
        .align(edge: .leading, constant: 16)
        .align(edge: .bottom, constant: 0)
        
        let showWeb = Binding(
            get: { homeUpdater.showMenu == .web },
            set: { homeUpdater.showMenu = $0 ? .web : .none }
        )
        
        if homeUpdater.showMenu == .web {
            HomeWeb(showWeb: showWeb)
        }
        
        GlassContainer {
            if homeUpdater.showMenu == .web { } else if homeUpdater.selecteds.isEmpty {
                Button {
                    homeUpdater.showMenu = .web
                } label: {
                    Image("globe")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(Color(uiColor: .label))
                        .frame(width: 60, height: 60)
                        .modifier(MainGlass(shape: .capsule, type: .clear))
                }
            } else {
                Button {
                    Task {
                        do {
                            homeUpdater.items = try await getItems()
                            homeUpdater.axis = .vertical
                            homeUpdater.showEdit = true
                        } catch {
                            print(error)
                        }
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(.vertical).frame(width: 20)
                        Text("Stitch Vertical")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundStyle(Color._white)
                    .padding(.horizontal, 20)
                    .frame(height: 60)
                    .modifier(MainGlass(shape: .capsule, type: .color(._primary)))
                }
            }
        }
        .align(edge: .trailing, constant: 16)
        .align(edge: .bottom, constant: 0)
    }
    
    private func getItems() async throws -> [StitchItem] {
        VIEW_CONTROLLER.startLoading("Loading 0 / \(homeUpdater.selecteds.count) Photos...")
        
        let items = await withTaskGroup(of: Optional<StitchItem>.self) { group in
            var items = [StitchItem]()
            
            for asset in homeUpdater.selecteds {
                group.addTask {
                    let item: StitchItem?
                    
                    do {
                        if asset.mediaType == .image {
                            item = try await PIPELINE.assetImageToItem(asset)
                        } else {
                            item = try await PIPELINE.assetVideoToItem(asset) { progress in
                                print(progress)
                            }
                        }
                    } catch {
                        print(error)
                        item = nil
                    }
                    
                    return item
                }
            }
            
            for await item in group {
                if let item = item {
                    items.append(item)
                    
                    VIEW_CONTROLLER.startLoading("Loading \(items.count) / \(homeUpdater.selecteds.count) Photos...")
                }
            }
            
            return try? items.sorted(by: { (homeUpdater.selecteds.firstIndex(of: try $0.asset.unwrap()) ?? 0) < (homeUpdater.selecteds.firstIndex(of: try $1.asset.unwrap()) ?? 0) })
        }
        
        guard let items = items else {
            throw MainError.error("No Items")
        }
        
        if homeUpdater.autoStitch {
            VIEW_CONTROLLER.startLoading("Auto Stitch...")
            try await PIPELINE.autoStitch(items)
        }
        
        await withCheckedContinuation { continuation in VIEW_CONTROLLER.stopLoading { continuation.resume() } }
        
        return items
    }
    
    private func getFilterCase() -> [PhotosFilter] {
        var cases = [PhotosFilter.all]
        
        if let album = homeUpdater.album {
            if album.assets.contains(where: { $0.mediaType == .image }) {
                cases.append(.images)
            }
            
            if album.assets.contains(where: { $0.mediaType == .video }) {
                cases.append(.videos)
            }
        }
        
        return cases
    }
}
