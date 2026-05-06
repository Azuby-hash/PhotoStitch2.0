//
//  Home.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 4/25/26.
//

import SwiftUI

struct Home: View {
    @State var updater = HomeUpdater()
    
    var body: some View {
        ZStack {
            Color(uiColor: .label).opacity(0.01).onTapGesture {
                updater.showMenu = .none
            }
            
            HomePhotos()
            HomeTop()
            HomeBottom()
        }
        .onAppear(perform: {
            AssetLibrary.shared.request { _ in
                updater.album = AssetLibrary.shared.getCurrentAlbum()
            }
        })
        .environment(updater)
        .animation(.smooth(duration: ANIM_DURATION), value: updater.showMenu)
        .animation(.smooth(duration: ANIM_DURATION), value: updater.removeOriginals)
        .animation(.smooth(duration: ANIM_DURATION), value: updater.autoStitch)
        .animation(.smooth(duration: ANIM_DURATION), value: updater.autoSelection)
    }
}

@Observable class HomeUpdater {
    enum MenuType {
        case settings
        case albums
        case filters
        case web
        case none
    }
    
    var album: ALInfo?
    var showMenu = MenuType.none
    
    var autoSelection = AUTO_SELECTION
    var autoStitch = AUTO_STITCH
    var removeOriginals = REMOVE_ORIGINALS
    var photofilter = PHOTO_FILTER
}

#Preview {
    Home()
}
