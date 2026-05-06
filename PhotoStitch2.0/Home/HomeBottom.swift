//
//  HomeBottom.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 5/3/26.
//

import SwiftUI

struct HomeBottom: View {
    @Environment(HomeUpdater.self) var updater
    
    var body: some View {
        GlassContainer {
            if updater.showMenu == .filters {
                VStack(spacing: 0) {
                    ForEach(PhotosFilter.allCases, id: \.self) { filter in
                        Button {
                            updater.photofilter = filter
                            updater.showMenu = .none
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: filter.icon)
                                    .frame(width: 20)
                                Text(filter.title)
                                Spacer()
                                Image(systemName: "checkmark")
                                    .opacity(updater.photofilter == filter ? 1 : 0)
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
            } else {
                Button {
                    updater.showMenu = .filters
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: updater.photofilter.icon)
                            .frame(width: 20)
                        Text(updater.photofilter.title)
                    }
                    .foregroundStyle(Color(uiColor: .label))
                    .padding(.horizontal, 20)
                    .frame(height: 60)
                    .modifier(MainGlass(shape: .capsule, type: .clear))
                }
            }
        }
        .align(edge: .leading, constant: 16)
        .align(edge: .bottom, constant: 0)
        
        GlassContainer {
            if updater.showMenu == .web {
                
            } else {
                Button {
                    updater.showMenu = .web
                } label: {
                    Image(systemName: "globe")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(Color(uiColor: .label))
                        .frame(width: 60, height: 60)
                        .modifier(MainGlass(shape: .capsule, type: .clear))
                }
            }
        }
        .align(edge: .trailing, constant: 16)
        .align(edge: .bottom, constant: 0)
    }
}
