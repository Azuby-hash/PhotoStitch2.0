//
//  Pipeline.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 5/10/26.
//

import SwiftUI
import Photos

class Pipeline {
    /**
     ONLY WORK on vertical, please limit in UI
     */
    static func autoStitch(_ items: [StitchItem]) async throws {
        guard items.count > 2 else {
            throw MainError.error("Some items not ready")
        }
        
        let date = Date()
        for index in items.dropLast().indices {
            let result = Stitch().stitch(before: items[index].process, after: items[index + 1].process, config: Stitch.getConfig(mode: .image))
            
            let maxKIndex = result.maxKIndex
            var maxBefore = result.maxBefore
            var maxAfter = result.maxAfter
            
            let beforeItem = items[index]
            let afterItem = items[index + 1]
            let beforeAverage = beforeItem.process.average
            let afterAverage = afterItem.process.average
            
            guard maxKIndex > beforeAverage.count / 50 && result.confidence > STITCH_CONFIDENCE && result.samePercent < STITCH_SAME_PERCENT else { continue }
            
            maxBefore = maxBefore + maxKIndex / 2
            maxAfter = maxAfter + maxKIndex / 2
            
            let beforeRect = CGRect(origin: beforeItem.process.rect.origin, maxOrigin: CGPoint(x: 1, y: CGFloat(beforeAverage.count - maxBefore) / CGFloat(beforeAverage.count)))
            let afterRect = CGRect(origin: CGPoint(x: 0, y: CGFloat(afterAverage.count - maxAfter) / CGFloat(afterAverage.count)), maxOrigin: CGPoint(x: 1, y: afterItem.process.rect.maxY))
            
            beforeItem.process.setRect(beforeRect)
            afterItem.process.setRect(afterRect)
        }
        
        print(date.timeIntervalSinceNow)
    }
    
    static func assetImageToItem(_ asset: PHAsset) async throws -> StitchItem {
        return try StitchItem(image: try AssetLibrary.getUIImage(from: asset))
    }
    
    static func assetVideoToItem(_ asset: PHAsset, progress: @escaping (CGFloat) -> Void) async throws -> StitchItem {
        let video: AVAsset? = await withCheckedContinuation { continuation in
            AssetLibrary.getAVAsset(asset) { result in
                continuation.resume(returning: result)
            }
        }
        
        guard let video = video else {
            throw MainError.error("Request video failed")
        }
        
        return try await Stitch().stitch(from: video, progress: progress)
    }
    
    /**
     USE WHEN PICK FROM PHOTOSUI
     */
    static func fixImageForOpenCV(_ image: UIImage) -> UIImage {
        let image = image.resize(size: image.size)

        guard let ciImage = CIImage(image: image),
              let cgImage = CICONTEXT.createCGImage(ciImage, from: ciImage.extent)
        else { return image }

        return UIImage(cgImage: cgImage)
    }
}
