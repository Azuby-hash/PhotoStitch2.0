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
            
            ZStack {
                if homeUpdater.showEdit {
                    Edit(editUpdater: EditUpdater(items: homeUpdater.items, axis: homeUpdater.axis))
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(homeUpdater.showEdit ? Color._background.ignoresSafeArea() : Color.clear.ignoresSafeArea())
        }
        .background(Color._background)
        .onAppear(perform: {
            Task {
                if !SHOW_ONBOARDING {
                    try? await homeUpdater.registerChange()
                    addNoti()
                    try? await StitchIntent.shared.trigger()
                }
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification), perform: { _ in
            Task {
                if !SHOW_ONBOARDING {
                    try? await homeUpdater.requestLibraryAccess()
                    try? await StitchIntent.shared.trigger()
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
                try? await homeUpdater.registerChange()
                addNoti()
                try? await StitchIntent.shared.trigger()
            }
        }) {
            Onboarding()
        }
        .fullScreenCover(isPresented: $homeUpdater.showSubscription) {
            Subscription()
        }
        .sheet(isPresented: $homeUpdater.showInstruction, content: {
            VideoInstruction()
        })
        .onReceive(NotificationCenter.default.publisher(for: StitchIntent.IMAGE_NOTI), perform: { _ in
            guard !homeUpdater.showEdit, let firstAsset = homeUpdater.filterAssets()?.first(where: { $0.mediaType == .image }) else { return }
            
            if let screenshotAlbum = homeUpdater.getAllAlbum().first(where: { $0.localizedTitle.contains("Screenshots") == true }) {
                homeUpdater.selectAlbum(screenshotAlbum)
            }
            
            homeUpdater.select(firstAsset, maxCount: 30)
            
            Task {
                do {
                    homeUpdater.items = try await homeUpdater.getItems()
                    homeUpdater.axis = .vertical
                    homeUpdater.showEdit = true
                } catch {
                    print(error)
                }
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: StitchIntent.VIDEO_NOTI), perform: { _ in
            guard !homeUpdater.showEdit, let firstAsset = homeUpdater.filterAssets()?.first(where: { $0.mediaType == .video }) else { return }
            
            if let screenshotAlbum = homeUpdater.getAllAlbum().first(where: { $0.localizedTitle.contains("Screenshots") == true }) {
                homeUpdater.selectAlbum(screenshotAlbum)
            }
            
            homeUpdater.select(firstAsset)
            
            Task {
                do {
                    homeUpdater.items = try await homeUpdater.getItems()
                    homeUpdater.axis = .vertical
                    homeUpdater.showEdit = true
                } catch {
                    print(error)
                }
            }
        })
        .environment(homeUpdater)
    }
    
    private func addNoti() {
        NotificationHelpers.requestForPushNotification { bool in
            let notis = [
                ("Time to stitch?", "Stop sending 5 separate screenshots. Combine them into one now!"),
                ("Ready for your next stitch?", "Your scrolling captures are waiting. Tap to make a long screenshot!"),
                ("Got a video scrollshot?", "Stitch it into a single clean image now!"),
                ("Long webpage capture?", "Stitch the whole page together now!"),
            ]
            
            if bool, let noti = notis.randomElement() {
                NotificationHelpers.scheduleNotification(title: noti.0, body: noti.1, id: "notification", dateComponents: .init(hour: 20, minute: 0, second: 0, weekday: .random(in: 1...5))) { }
            }
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
    
    private(set) var selecteds: [PHAsset] = []
    
    var showMenu = MenuType.none
    var showOnboarding = SHOW_ONBOARDING
    var showSubscription = false
    var showInstruction = false {
        didSet {
            if !showInstruction {
                AUTO_SHOW_INSTRUCTION = false
            }
        }
    }

    var autoSelection = AUTO_SELECTION {
        didSet {
            AUTO_SELECTION = autoSelection
        }
    }
    var autoStitch = AUTO_STITCH {
        didSet {
            AUTO_STITCH = autoStitch
        }
    }
    var removeOriginals = REMOVE_ORIGINALS {
        didSet {
            REMOVE_ORIGINALS = removeOriginals
        }
    }
    var photofilter = PHOTO_FILTER {
        didSet {
            PHOTO_FILTER = photofilter
            
            if photofilter != .images && AUTO_SHOW_INSTRUCTION {
                showInstruction = true
            }
        }
    }
    
    private(set) var warningText = ""
    @ObservationIgnored private var warningTask: Task<Void, Never>?
    
    var showEdit = false
    @ObservationIgnored var items: [StitchItem] = []
    @ObservationIgnored var axis: NSLayoutConstraint.Axis = .vertical
    
    func select(_ asset: PHAsset, maxCount: Int = 4) {
        if selecteds.contains(where: { $0.mediaType == .video }),
           asset.mediaType == .video {
            warningAlert("Only one video can be selected at a time.")
            return
        }
        
        do {
            try autoSelection(for: asset, maxCount: maxCount)
        } catch {
            print(error)
        }
        
        let lastIsVideo = selecteds.last?.mediaType == .video
        
        if handleMaxSelection() {
            if lastIsVideo {
                warningAlert("This video exceeds the maximum duration.")
            } else {
                warningAlert("Maximum number of items reached.")
            }
        }
    }
    
    func deselect(_ asset: PHAsset) {
        selecteds = selecteds.filter({ $0 != asset })
    }
    
    func setSelect(_ assets: [PHAsset]) {
        let curr = selecteds
        selecteds = assets
        
        if handleMaxSelection() {
            selecteds = curr
        }
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
    
    @discardableResult
    private func handleMaxSelection() -> Bool {
        var total = selecteds.reduce(0.0) { sum, asset in
            asset.mediaType == .video ? (sum + asset.duration / SECOND_PER_SELECTION) : (sum + 1)
        }
        
        let begin = total
        
        while total > Double(MAX_SELECTION), !selecteds.isEmpty {
            let removed = selecteds.removeLast()
            total -= removed.mediaType == .video ? (removed.duration / SECOND_PER_SELECTION) : 1
        }
        
        return begin != total
    }
    
    private func autoSelection(for asset: PHAsset, maxCount: Int) throws {
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
            
            if calendar.isDate(currDate, inSameDayAs: date), abs(date.timeIntervalSince(currDate)) < INTERVAL_AUTO, pendingSelecteds.count < maxCount {
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
        Task { try? await requestLibraryAccess() }
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
    func getItems() async throws -> [StitchItem] {
        VIEW_CONTROLLER.startLoading("Loading 0 / \(selecteds.count) Photos...")
        
        let items = await withTaskGroup(of: Optional<StitchItem>.self) { group in
            var items = [StitchItem]()
            
            for asset in selecteds {
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
                    
                    VIEW_CONTROLLER.startLoading("Loading \(items.count) / \(selecteds.count) Photos...")
                }
            }
            
            return try? items.sorted(by: { (selecteds.firstIndex(of: try $0.asset.unwrap()) ?? 0) < (selecteds.firstIndex(of: try $1.asset.unwrap()) ?? 0) })
        }
        
        guard let items = items else {
            throw MainError.error("No Items")
        }
        
        if autoStitch {
            VIEW_CONTROLLER.startLoading("Auto Stitch...")
            try await PIPELINE.autoStitch(items)
        }
        
        await withCheckedContinuation { continuation in VIEW_CONTROLLER.stopLoading { continuation.resume() } }
        
        return items
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
