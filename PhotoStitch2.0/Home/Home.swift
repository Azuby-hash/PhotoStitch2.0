//
//  Home.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 4/25/26.
//

import SwiftUI
import Photos

struct Home: View {
    @State var updater = HomeUpdater()
    
    var body: some View {
        ZStack {
            HomePhotos()
            
            if updater.showMenu != .none {
                Color(uiColor: .label).opacity(0.01).onTapGesture {
                    updater.showMenu = .none
                }
            }
            
            HomeTop()
            HomeBottom()
        }
        .background(Color._background)
        .onAppear(perform: {
            if !SHOW_ONBOARDING {
                updater.registerChange()
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification), perform: { _ in
            if !SHOW_ONBOARDING {
                updater.requestLibraryAccess()
            }
        })
        .environment(updater)
        .animation(.smooth(duration: ANIM_DURATION), value: updater.showMenu)
        .animation(.smooth(duration: ANIM_DURATION), value: updater.selecteds)
        .animation(.smooth(duration: ANIM_DURATION), value: updater.removeOriginals)
        .animation(.smooth(duration: ANIM_DURATION), value: updater.autoStitch)
        .animation(.smooth(duration: ANIM_DURATION), value: updater.autoSelection)
        .fullScreenCover(isPresented: $updater.showOnboarding, onDismiss: {
            SHOW_ONBOARDING = false
            updater.registerChange()
        }) {
            Onboarding()
        }
        .fullScreenCover(isPresented: $updater.showSubscription) {
            Subscription()
        }
    }
}

@Observable class HomeUpdater: NSObject {
    @ObservationIgnored private let library = AssetLibrary()
    
    enum MenuType {
        case settings
        case albums
        case filters
        case web
        case none
    }
    
    private(set) var album: ALInfo?
    
    var selecteds: [PHAsset] = []
    
    var showMenu = MenuType.none
    var showOnboarding = SHOW_ONBOARDING
    var showSubscription = false

    var autoSelection = AUTO_SELECTION
    var autoStitch = AUTO_STITCH
    var removeOriginals = REMOVE_ORIGINALS
    var photofilter = PHOTO_FILTER
}

extension HomeUpdater: PHPhotoLibraryChangeObserver {
    func registerChange(completion: (() -> Void)? = nil) {
        PHPhotoLibrary.shared().register(self)
        requestLibraryAccess(completion: completion)
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async { [self] in
            requestLibraryAccess()
        }
    }
    
    func requestLibraryAccess(completion: (() -> Void)? = nil) {
        selecteds.removeAll()
        
        library.request { [self] _ in
            selectAlbum(library.getAllAlbum().first)
        }
    }
}

extension HomeUpdater {
    func getAllAlbum() -> [ALInfo] {
        return library.getAllAlbum()
    }
    
    func selectAlbum(_ info: ALInfo?) {
        album = info
        selecteds.removeAll()
        
        if let info = info {
            if !info.assets.contains(where: { $0.mediaType == .image }), photofilter == .images {
                photofilter = .all
            }
            
            if !info.assets.contains(where: { $0.mediaType == .video }), photofilter == .videos {
                photofilter = .all
            }
        }
    }
}

extension HomeUpdater {
    func warningAlert(_ string: String) {
        
    }
}

#Preview {
    Home()
}
