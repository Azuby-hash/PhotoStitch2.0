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
            if homeUpdater.showMenu == .filters {
                VStack(spacing: 0) {
                    ForEach(getFilterCase(), id: \.self) { filter in
                        Button {
                            homeUpdater.photofilter = filter
                            homeUpdater.showMenu = .none
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: filter.icon)
                                    .frame(width: 20)
                                Text(filter.title)
                                Spacer()
                                Image(systemName: "checkmark")
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
                        Image(systemName: homeUpdater.photofilter.icon)
                            .frame(width: 20)
                        Text(homeUpdater.photofilter.title)
                    }
                    .foregroundStyle(Color(uiColor: .label))
                    .padding(.horizontal, 20)
                    .frame(height: 60)
                    .modifier(MainGlass(shape: .capsule, type: .clear))
                }
            } else {
                Button {
                    
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
        
        GlassContainer {
            if homeUpdater.showMenu == .web {
                
            } else if homeUpdater.selecteds.isEmpty {
                Button {
                    homeUpdater.showMenu = .web
                } label: {
                    Image(systemName: "globe")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(Color(uiColor: .label))
                        .frame(width: 60, height: 60)
                        .modifier(MainGlass(shape: .capsule, type: .clear))
                }
            } else {
                Button {
                    Task {
                        var items = [StitchItem]()
                        
                        for asset in homeUpdater.selecteds {
                            if asset.mediaType == .image {
                                items.append(try await Pipeline.assetImageToItem(asset))
                            } else {
                                items.append(try await Pipeline.assetVideoToItem(asset) { progress in
                                    print(progress)
                                })
                            }
                        }
                        
                        if homeUpdater.autoStitch {
                            try await Pipeline.autoStitch(items)
                        }
                        
                        homeUpdater.items = items
                        homeUpdater.axis = .vertical
                        homeUpdater.showEdit = true
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(.vertical).frame(width: 20)
                        Text("Stitch Vertical")
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
