//
//  HomeTop.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 5/3/26.
//

import SwiftUI

struct HomeTop: View {
    @Environment(HomeUpdater.self) var homeUpdater
    
    var body: some View {
        HStack(alignment: .top, spacing: homeUpdater.selecteds.isEmpty ? -1000 : 16) {
            HStack(alignment: .top) {
                if homeUpdater.photofilter != .images {
                    Button {
                        homeUpdater.showInstruction = true
                    } label: {
                        HStack {
                            Image("questionmark")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.white)
                        }
                        .frame(width: 32, height: 32)
                        .modifier(MainGlass(shape: .capsule, type: .color(._primary)))
                    }
                    .padding(.top, 6)
                }
                
                GlassContainer {
                    if homeUpdater.showMenu == .albums {
                        VStack(spacing: 0) {
                            ForEach(homeUpdater.getAllAlbum(), id: \.localizedTitle) { album in
                                Button {
                                    homeUpdater.selectAlbum(album)
                                    homeUpdater.showMenu = .none
                                } label: {
                                    HStack(spacing: 12) {
                                        Text(album.getName())
                                        Spacer()
                                        Image("checkmark")
                                            .opacity(homeUpdater.album?.getName() == album.getName() ? 1 : 0)
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
                        if homeUpdater.selecteds.isEmpty {
                            Button {
                                if !homeUpdater.getAllAlbum().isEmpty {
                                    homeUpdater.showMenu = .albums
                                }
                            } label: {
                                HStack {
                                    Text(homeUpdater.album?.getName() ?? "Loading...")
                                        .font(.system(size: 26, weight: .bold, design: .rounded))
                                    Image("arrowtriangle.down.fill")
                                        .resizable()
                                        .frame(width: 10, height: 7)
                                        .modifier(MainGlass(shape: .capsule, type: .clear))
                                }
                                .foregroundStyle(Color.primary)
                                .frame(height: 44)
                            }
                        } else {
                            HStack {
                                Text(homeUpdater.album?.getName() ?? "Loading...")
                                    .font(.system(size: 26, weight: .bold, design: .rounded))
                            }
                            .foregroundStyle(Color.primary)
                            .frame(height: 44)
                        }
                    }
                }
            }
            
            Spacer()
            
            GlassContainer {
                if homeUpdater.showMenu == .settings {
                    HomeMenu()
                } else if homeUpdater.selecteds.isEmpty {
                    Button {
                        homeUpdater.showMenu = .settings
                    } label: {
                        Image("line.3.horizontal.decrease")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(Color(uiColor: .label))
                            .frame(width: 44, height: 44)
                            .modifier(MainGlass(shape: .capsule, type: .clear))
                    }
                } else {
                    Button {
                        homeUpdater.deselectAll()
                    } label: {
                        HStack {
                            Text("\(homeUpdater.selecteds.count)")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(uiColor: .label))
                                .frame(width: 32, height: 32)
                                .background(.ultraThinMaterial)
                                .clipShape(.capsule)
                            Text("Deselect All")
                                .font(.system(size: 18, weight: .semibold))
                                .frame(maxWidth: .infinity)
                        }
                        .foregroundStyle(Color(uiColor: ._red))
                        .padding(.leading, 6)
                        .padding(.trailing, 16)
                        .frame(height: 44)
                        .modifier(MainGlass(shape: .capsule, type: .clear))
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .align(edge: .top, constant: 0)
    }
}

struct HomeMenu: View {
    @Environment(HomeUpdater.self) var homeUpdater
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Settings")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Color(uiColor: .tertiaryLabel))
                .align(edge: .leading, constant: 8)
                .padding(.top, 4)
                .padding(.bottom, 10)
            
            Button {
                homeUpdater.autoSelection.toggle()
            } label: {
                HStack(spacing: 12) {
                    Image("app.badge.checkmark.fill")
                        .frame(width: 20)
                    Text("Auto Selection")
                        .font(.system(size: 16, weight: .regular))
                    Spacer()
                    Image("checkmark")
                        .opacity(homeUpdater.autoSelection ? 1 : 0)
                }
                .foregroundStyle(Color(uiColor: .label))
                .frame(height: 40)
            }
            
            Button {
                homeUpdater.autoStitch.toggle()
            } label: {
                HStack(spacing: 12) {
                    Image("arrowtriangle.right.and.line.vertical.and.arrowtriangle.left.fill")
                        .rotationEffect(.radians(.pi / 2))
                        .frame(width: 20)
                    Text("Auto Stitch at startup")
                        .font(.system(size: 16, weight: .regular))
                    Spacer()
                    Image("checkmark")
                        .opacity(homeUpdater.autoStitch ? 1 : 0)
                }
                .foregroundStyle(Color(uiColor: .label))
                .frame(height: 40)
            }
            
            Button {
                var rawValue = homeUpdater.removeOriginals.rawValue
                rawValue = (rawValue + 1) == RemoveOriginals.allCases.count ? 0 : (rawValue + 1)
                
                homeUpdater.removeOriginals = RemoveOriginals(rawValue: rawValue) ?? homeUpdater.removeOriginals
            } label: {
                HStack(spacing: 12) {
                    Image("archivebox.fill")
                        .frame(width: 20)
                    Text("Remove Originals")
                        .font(.system(size: 16, weight: .regular))
                    Spacer()
                    Text(homeUpdater.removeOriginals.title)
                        .foregroundStyle(homeUpdater.removeOriginals.color)
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
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            } label: {
                HStack(spacing: 12) {
                    Image("gear")
                        .frame(width: 20)
                    Text("Access Settings")
                        .font(.system(size: 16, weight: .regular))
                    Spacer()
                    Image("chevron.right")
                        .foregroundStyle(Color(uiColor: .tertiaryLabel))
                }
                .foregroundStyle(Color(uiColor: .label))
                .frame(height: 40)
            }
            
            Button {
                let email = "azuby.dev@gmail.com"
                if let url = URL(string: "mailto:\(email)?subject=Photo Stitch Feedback") {
                    UIApplication.shared.open(url)
                }
            } label: {
                HStack(spacing: 12) {
                    Image("ellipsis.bubble.fill")
                        .frame(width: 20)
                    Text("Write a feedback")
                        .font(.system(size: 16, weight: .regular))
                    Spacer()
                    Image("chevron.right")
                        .foregroundStyle(Color(uiColor: .tertiaryLabel))
                }
                .foregroundStyle(Color(uiColor: .label))
                .frame(height: 40)
            }
            
            Button {
                if let url = URL(string: "https://apps.apple.com/us/app/photo-stitch/id6746974251") {
                    UIApplication.shared.open(url)
                }
            } label: {
                HStack(spacing: 12) {
                    Image("arrowshape.turn.up.forward.circle.fill")
                        .frame(width: 20)
                    Text("Share this app")
                        .font(.system(size: 16, weight: .regular))
                    Spacer()
                    Image("chevron.right")
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
                if let url = URL(string: "https://azuby-hash.github.io/AzubyTerms/") {
                    UIApplication.shared.open(url)
                }
            } label: {
                HStack(spacing: 12) {
                    Image("list.clipboard.fill")
                        .frame(width: 20)
                    Text("Term of Service")
                        .font(.system(size: 16, weight: .regular))
                    Spacer()
                    Image("chevron.right")
                        .foregroundStyle(Color(uiColor: .tertiaryLabel))
                }
                .foregroundStyle(Color(uiColor: .label))
                .frame(height: 40)
            }
            
            Button {
                if let url = URL(string: "https://azuby-hash.github.io/AzubyPrivacy/") {
                    UIApplication.shared.open(url)
                }
            } label: {
                HStack(spacing: 12) {
                    Image("lock.shield.fill")
                        .frame(width: 20)
                    Text("Privacy Policy")
                        .font(.system(size: 16, weight: .regular))
                    Spacer()
                    Image("chevron.right")
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
