//
//  Home.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 4/25/26.
//

import SwiftUI
import Photos
import Combine

struct Home: View {
    @State var homeUpdater = HomeUpdater()
    
    var body: some View {
        ZStack {
            HomePhotos()
            
            if homeUpdater.showMenu != .none {
                Color(uiColor: .label).opacity(0.01).onTapGesture {
                    homeUpdater.showMenu = .none
                }
            }
            
            HomeTop()
            HomeBottom()
            
            if !homeUpdater.warningText.isEmpty {
                Text(homeUpdater.warningText)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color._background)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 0)
                    .padding(.horizontal, 16)
                    .transition(.blurReplace.combined(with: .opacity))
                    .allowsHitTesting(false)
                    .zIndex(1000)
            }
            
            if homeUpdater.showEdit {
                Edit(editUpdater: EditUpdater(items: homeUpdater.items, axis: homeUpdater.axis)).transition(.move(edge: .top))
            }
        }
        .background(Color._background)
        .onAppear(perform: {
            Task {
                if !SHOW_ONBOARDING {
                    try await homeUpdater.registerChange()
                }
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification), perform: { _ in
            Task {
                if !SHOW_ONBOARDING {
                    try await homeUpdater.requestLibraryAccess()
                }
            }
        })
        .onChange(homeUpdater.showEdit, perform: { showEdit in
            if !showEdit {
                homeUpdater.items = []
                homeUpdater.axis = .vertical
            }
        })
        .animation(.smooth(duration: ANIM_DURATION), value: homeUpdater.warningText)
        .animation(.smooth(duration: ANIM_DURATION), value: homeUpdater.showEdit)
        .animation(.smooth(duration: ANIM_DURATION), value: homeUpdater.showMenu)
        .animation(.smooth(duration: ANIM_DURATION), value: homeUpdater.selecteds)
        .animation(.smooth(duration: ANIM_DURATION), value: homeUpdater.removeOriginals)
        .animation(.smooth(duration: ANIM_DURATION), value: homeUpdater.autoStitch)
        .animation(.smooth(duration: ANIM_DURATION), value: homeUpdater.autoSelection)
        .fullScreenCover(isPresented: $homeUpdater.showOnboarding, onDismiss: {
            Task {
                SHOW_ONBOARDING = false
                try await homeUpdater.registerChange()
            }
        }) {
            Onboarding()
        }
        .fullScreenCover(isPresented: $homeUpdater.showSubscription) {
            Subscription()
        }
        .environment(homeUpdater)
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
    
    private(set) var selecteds: [PHAsset] = []
    
    var showMenu = MenuType.none
    var showOnboarding = SHOW_ONBOARDING
    var showSubscription = false

    var autoSelection = AUTO_SELECTION
    var autoStitch = AUTO_STITCH
    var removeOriginals = REMOVE_ORIGINALS
    var photofilter = PHOTO_FILTER
    
    private(set) var warningText = ""
    @ObservationIgnored private var warningTask: Task<Void, Never>?
    
    var showEdit = false
    @ObservationIgnored var items: [StitchItem] = []
    @ObservationIgnored var axis: NSLayoutConstraint.Axis = .vertical
    
    func select(_ asset: PHAsset) {
        if selecteds.contains(where: { $0.mediaType == .video }),
           asset.mediaType == .video {
            warningAlert("Please select only one video!")
            return
        }
        
        do {
            try autoSelection(for: asset)
        } catch {
            print(error)
        }
    }
    
    func deselect(_ asset: PHAsset) {
        selecteds = selecteds.filter({ $0 != asset })
    }
    
    func deselectAll() {
        selecteds.removeAll()
    }
    
    func filterAssets() -> [PHAsset]? {
        return album?.assets.filter({
            if photofilter == .images {
                return $0.mediaType == .image
            }
            
            if photofilter == .videos {
                return $0.mediaType == .video
            }
            
            return true
        })
    }
    
    private func autoSelection(for asset: PHAsset) throws {
        guard var currDate = asset.creationDate,
              let assets = filterAssets(),
              let firstIndex = assets.firstIndex(of: asset)
        else { throw MainError.error("No asset") }
        
        guard autoSelection, asset.mediaType != .video else {
            selecteds.append(asset)
            return
        }

        let calendar = Calendar.current
        
        var currAsset = asset
        var pendingSelecteds = [currAsset]
        
        for (index, asset) in assets.enumerated() {
            guard let date = asset.creationDate,
                  index > firstIndex,
                  asset != currAsset,
                  asset.mediaType != .video
            else { continue }
            
            if calendar.isDate(currDate, inSameDayAs: date), abs(date.timeIntervalSince(currDate)) < INTERVAL_AUTO, pendingSelecteds.count < 4 {
                pendingSelecteds.append(asset)
                currAsset = asset
                currDate = date
            } else {
                break
            }
        }
        
        pendingSelecteds = pendingSelecteds.sorted(by: {
            guard let date1 = $0.creationDate,
                  let date2 = $1.creationDate
            else { return false }
            
            return date1 < date2
        })
        
        for asset in pendingSelecteds {
            if !selecteds.contains(asset) {
                selecteds.append(asset)
            }
        }
    }
}

extension HomeUpdater: PHPhotoLibraryChangeObserver {
    func registerChange() async throws {
        PHPhotoLibrary.shared().register(self)
        try await requestLibraryAccess()
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        Task { try await requestLibraryAccess() }
    }
    
    func requestLibraryAccess() async throws {
        selecteds.removeAll()
        
        try await library.request()
        selectAlbum(library.getAllAlbum().first(where: { $0.localizedTitle == ALBUM_SELECT }) ?? library.getAllAlbum().first)
    }
}

extension HomeUpdater {
    func getAllAlbum() -> [ALInfo] {
        return library.getAllAlbum()
    }
    
    func selectAlbum(_ info: ALInfo?) {
        album = info
        ALBUM_SELECT = info?.localizedTitle
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
        warningTask?.cancel()
        warningText = string
        warningTask = Task {
            try? await Task.sleep(for: .seconds(2))

            if !Task.isCancelled {
                await MainActor.run {
                    warningText = ""
                }
            }
        }
    }
}

#Preview {
    Home()
}
