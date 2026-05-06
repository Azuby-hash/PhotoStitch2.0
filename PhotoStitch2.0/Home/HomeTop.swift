//
//  HomeTop.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 5/3/26.
//

import SwiftUI

struct HomeTop: View {
    @Environment(HomeUpdater.self) var updater
    
    var body: some View {
        GlassContainer {
            if updater.showMenu == .albums {
                VStack(spacing: 0) {
                    ForEach(AssetLibrary.shared.getAllAlbum(), id: \.localizedTitle) { album in
                        Button {
                            updater.album = album
                            updater.showMenu = .none
                        } label: {
                            HStack(spacing: 12) {
                                Text(album.getName())
                                Spacer()
                                Image(systemName: "checkmark")
                                    .opacity(updater.album?.getName() == album.getName() ? 1 : 0)
                            }
                            .foregroundStyle(Color(uiColor: .label))
                            .frame(height: 40)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .frame(maxWidth: 240)
                .modifier(MainGlass(shape: RoundedRectangle(cornerRadius: 24), type: .clear))
            } else {
                Button {
                    updater.showMenu = .albums
                } label: {
                    HStack {
                        Text(updater.album?.getName() ?? "Recents")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                        Image(systemName: "arrowtriangle.down.fill")
                            .resizable()
                            .frame(width: 10, height: 7)
                            .modifier(GlassModifier(shape: .capsule))
                    }
                    .frame(height: 44)
                }
                .foregroundStyle(Color.primary)
            }
        }
        .align(edge: .leading, constant: 16)
        .align(edge: .top, constant: 0)
        
        GlassContainer {
            if updater.showMenu == .settings {
                HomeMenu()
            } else {
                Button {
                    updater.showMenu = .settings
                } label: {
                    Image(systemName: "line.3.horizontal.decrease")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(Color(uiColor: .label))
                        .frame(width: 44, height: 44)
                        .modifier(MainGlass(shape: .capsule, type: .clear))
                }
            }
        }
        .align(edge: .trailing, constant: 0)
        .padding(.horizontal, 16)
        .align(edge: .top, constant: 0)
    }
}

struct HomeMenu: View {
    @Environment(HomeUpdater.self) var updater
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Settings")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Color(uiColor: .tertiaryLabel))
                .align(edge: .leading, constant: 8)
                .padding(.top, 4)
                .padding(.bottom, 10)
            
            Button {
                updater.autoSelection.toggle()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "app.badge.checkmark.fill")
                        .frame(width: 20)
                    Text("Auto Selection")
                        .font(.system(size: 16, weight: .regular))
                    Spacer()
                    Image(systemName: "checkmark")
                        .opacity(updater.autoSelection ? 1 : 0)
                }
                .foregroundStyle(Color(uiColor: .label))
                .frame(height: 40)
            }
            
            Button {
                updater.autoStitch.toggle()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "arrowtriangle.right.and.line.vertical.and.arrowtriangle.left.fill")
                        .rotationEffect(.radians(.pi / 2))
                        .frame(width: 20)
                    Text("Auto Stitch at startup")
                        .font(.system(size: 16, weight: .regular))
                    Spacer()
                    Image(systemName: "checkmark")
                        .opacity(updater.autoStitch ? 1 : 0)
                }
                .foregroundStyle(Color(uiColor: .label))
                .frame(height: 40)
            }
            
            Button {
                var rawValue = updater.removeOriginals.rawValue
                rawValue = (rawValue + 1) == RemoveOriginals.allCases.count ? 0 : (rawValue + 1)
                
                updater.removeOriginals = RemoveOriginals(rawValue: rawValue) ?? updater.removeOriginals
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "archivebox.fill")
                        .frame(width: 20)
                    Text("Remove Originals")
                        .font(.system(size: 16, weight: .regular))
                    Spacer()
                    Text(updater.removeOriginals.title)
                        .foregroundStyle(updater.removeOriginals.color)
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundStyle(Color(uiColor: .label))
                .frame(height: 40)
            }
            
            VStack {
                Divider()
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 8)
            }
            .frame(height: 21)
            
            Text("Access")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Color(uiColor: .tertiaryLabel))
                .align(edge: .leading, constant: 8)
                .padding(.top, 4)
                .padding(.bottom, 10)
            
            Button {
                
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "gear")
                        .frame(width: 20)
                    Text("Access Settings")
                        .font(.system(size: 16, weight: .regular))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color(uiColor: .tertiaryLabel))
                }
                .foregroundStyle(Color(uiColor: .label))
                .frame(height: 40)
            }
            
            Button {
                
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "ellipsis.bubble.fill")
                        .frame(width: 20)
                    Text("Write a feedback")
                        .font(.system(size: 16, weight: .regular))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color(uiColor: .tertiaryLabel))
                }
                .foregroundStyle(Color(uiColor: .label))
                .frame(height: 40)
            }
            
            Button {
                
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "arrowshape.turn.up.forward.circle.fill")
                        .frame(width: 20)
                    Text("Share this app")
                        .font(.system(size: 16, weight: .regular))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color(uiColor: .tertiaryLabel))
                }
                .foregroundStyle(Color(uiColor: .label))
                .frame(height: 40)
            }
            
            VStack {
                Divider()
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 8)
            }
            .frame(height: 21)
            
            Button {
                
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "list.clipboard.fill")
                        .frame(width: 20)
                    Text("Term of Service")
                        .font(.system(size: 16, weight: .regular))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color(uiColor: .tertiaryLabel))
                }
                .foregroundStyle(Color(uiColor: .label))
                .frame(height: 40)
            }
            
            Button {
                
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "lock.shield.fill")
                        .frame(width: 20)
                    Text("Privacy Policy")
                        .font(.system(size: 16, weight: .regular))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color(uiColor: .tertiaryLabel))
                }
                .foregroundStyle(Color(uiColor: .label))
                .frame(height: 40)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .frame(maxWidth: 280)
        .modifier(MainGlass(shape: RoundedRectangle(cornerRadius: 24), type: .clear))
        .align(edge: .top, constant: 0)
    }
}
