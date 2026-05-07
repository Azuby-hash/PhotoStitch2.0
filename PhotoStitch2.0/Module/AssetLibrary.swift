//
//  AssetLibrary2.swift
//  ModuleTest
//
//  Created by TapUniverse Dev9 on 20/09/2023.
//

import UIKit
import Photos

class ALInfo {
    private(set) var assets: [PHAsset]
    private(set) var localizedTitle: String
    private(set) var subType: PHAssetCollectionSubtype
    
    init(assets: [PHAsset], localizedTitle: String, subType: PHAssetCollectionSubtype) {
        self.assets = assets
        self.localizedTitle = localizedTitle
        self.subType = subType
    }
    
    /**
     Return number of assets in album
     */
    func getCount() -> Int {
        return assets.count
    }
    
    /**
     Return asset at index
     
     - Parameters:
        - index: Index of asset in album
     */
    func getAsset(at index: Int) -> PHAsset? {
        if getCount() > index {
            return assets[index]
        }
        return nil
    }
    
    /**
     Return album's name
     */
    func getName() -> String {
        return localizedTitle
    }
}

/**
 Available for iOS 14 or upper
 
 > Important: Run **request()** before using other function
 
 - AssetLibrary need user permission to access and fetch data so **request()** must run first.
 - After run **request()** you can use other function has their discription
 
 **Setup example**
 ```
 override func viewDidLoad() {
    super.viewDidLoad()
    
    request { status in
        // do some stuff with return status
    }
 }
 ```
   
 */
class AssetLibrary {
    private var albums: [ALInfo] = []
    private var didFetch = false
    
    /**
     Request user permisstion and fetch data
     
     - Parameters:
        - forceSettings: A Boolean value indicating whether need open settings immediately when user cancel access permission
        - completion: An action after get permission and fetch data
     
     */
    func request(forceSettings: Bool = false, completion: ((PHAuthorizationStatus)->Void)? = nil) {
        DispatchQueue.global(qos: .default).async { [self] in
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            
            if status == .notDetermined {
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { [self] status in
                    request(forceSettings: forceSettings, completion: completion)
                }
                return
            }
            
            if status == .denied || status == .restricted {
                DispatchQueue.main.async {
                    if forceSettings {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                    }
                    completion?(status)
                }
                return
            }
            
            fetchAlbumData()
            
            DispatchQueue.main.async {
                completion?(status)
            }
        }
    }
    
    /**
     Return current album settings status
     */
    static func getCurrentStatus() -> PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }

    /**
     Return all available album
     - Parameters:
        - infoOnly: No asset was take, use for getName() only
     */
    func getAllAlbum(_ infoOnly: Bool = false) -> [ALInfo] {
        return albums
    }
    
    /**
     Get UIImage from PHAsset
     
     > Important: if size is negative number this will export full size
     
     - Parameters:
        - asset: Input asset
        - size: Expect size to export, default is full size
        - quality: Expect image quality to export, default is .highQualityFormat
        - resizeMode: Expect mode to export, default is .fast
     */
    static func getUIImage(from asset: PHAsset, size: CGSize = CGSize(width: -1, height: -1), quality: PHImageRequestOptionsDeliveryMode = .highQualityFormat, resizeMode: PHImageRequestOptionsResizeMode = .fast, completion: ((UIImage)->Void)? = nil) {
        DispatchQueue.global(qos: .default).async {
            var size = size
            if size.width < 0 {
                size = CGSize(width: CGFloat(asset.pixelWidth), height: CGFloat(asset.pixelHeight))
            }
            
            let manager = PHImageManager.default()
            let options = PHImageRequestOptions()
            
            options.deliveryMode = quality
            options.resizeMode = resizeMode
            options.isNetworkAccessAllowed = true
            
            manager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options, resultHandler: {(result, _)->Void in
                guard let result = result else {
                    return
                }

                DispatchQueue.main.async {
                    completion?(result)
                }
            })
        }
    }
    
    /**
     Delete asset in library
     
     - Parameters:
        - assets: Array of asset need to delete
        - completion: Handler return boolean declare asset delete success or not
     */
    static func deleteImage(assets: [PHAsset?], completion: @escaping (Bool)->Void) {
        let locals = assets.map { asset -> String in
            if let asset = asset{
                return asset.localIdentifier
            }
            return ""
        }.filter { path in
            return path != ""
        }
        PHPhotoLibrary.shared().performChanges({
            let imageAssetToDelete = PHAsset.fetchAssets(withLocalIdentifiers: locals, options: nil)
            PHAssetChangeRequest.deleteAssets(imageAssetToDelete)
        }, completionHandler: { success, error in
            completion(success)
        })
    }
    
    /**
     Get asset type such as PNG, JPEG,...
     */
    static func getSourceType(_ asset: PHAsset) -> String{
        let resource = PHAssetResource.assetResources(for: asset)
        var name = "Unknown"
        for r in resource{
            if r.type == .photo{
                name = "\(r.uniformTypeIdentifier.split(separator: ".")[1])"
                name = name.uppercased()
            }
        }
        return name
    }
    
    /**
     Get asset from specific assetID
     */
    static func getAsset(from assetID: String) -> PHAsset? {
        return PHAsset.fetchAssets(withLocalIdentifiers: [assetID], options: nil).firstObject
    }
    
    /**
     Get multi asset from multi specific assetID
     */
    static func getAssets(from assetID: String) -> [PHAsset] {
        var assets = [PHAsset]()
        
        PHAsset.fetchAssets(withLocalIdentifiers: [assetID], options: nil).enumerateObjects { asset, _, _ in
            assets.append(asset)
        }
        
        return assets
    }
    
    /**
     Get assetID for later to get just one specific asset only
     */
    static func getAssetID(from asset: PHAsset) -> String {
        return asset.localIdentifier
    }
    
    /**
     Get AVAsset from PHAsset
     */
    static func getAVAsset(_ asset: PHAsset, deliveryMode: PHVideoRequestOptionsDeliveryMode = .highQualityFormat, completion: @escaping (AVAsset?) -> Void) {
        let option = PHVideoRequestOptions()
        option.deliveryMode = deliveryMode
        option.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestAVAsset(forVideo: asset, options: option) { avAsset, _, _ in
            DispatchQueue.main.async {
                completion(avAsset)
            }
        }
    }
}

extension AssetLibrary {
    private func fetchAlbumData() {
        albums.removeAll()
        
        func append(_ result: PHFetchResult<PHAsset>, _ name: String, _ subType: PHAssetCollectionSubtype) {
            if result.count <= 0 { return }
            
            var assets = [PHAsset]()
            result.enumerateObjects { asset, _, _ in
                assets.append(asset)
            }
            
            albums.append(ALInfo(assets: assets.reversed(), localizedTitle: name, subType: subType))
        }
        
        let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        
        [userAlbums, smartAlbums].forEach({
            $0.enumerateObjects { [self] (collection, _, _) in
                let fetchOptions = PHFetchOptions()
                let result = PHAsset.fetchAssets(in: collection, options: fetchOptions)
                let count = result.count
                
                if count > 0 && !albums.contains(where: { $0.getName().contains(collection.localizedTitle ?? UUID().uuidString) }) {
                    append(result, collection.localizedTitle ?? "", collection.assetCollectionSubtype)
                }
            }
        })
        
        if let recents = albums.first(where: { $0.getName().lowercased().contains("recents") }) {
            albums = [recents] + albums.filter({ $0.getName() != recents.getName() })
        }
        
        let screenshotAssets = albums.filter({ $0.subType == .smartAlbumScreenshots || $0.subType == .smartAlbumScreenRecordings }).flatMap({ $0.assets })
        let screenshotInfo = ALInfo(assets: screenshotAssets, localizedTitle: "Screenshots", subType: .smartAlbumScreenshots)
        
        albums = albums.filter({ $0.subType != .smartAlbumScreenshots && $0.subType != .smartAlbumScreenRecordings })
        
        if screenshotAssets.count > 0 {
            albums.insert(screenshotInfo, at: 0)
        }
    }
}
