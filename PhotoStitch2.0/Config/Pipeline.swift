//
//  Pipeline.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 5/10/26.
//

import SwiftUI
import Photos

@globalActor
actor PipelineActor {
    static let shared = PipelineActor()
}

let PIPELINE = Pipeline()

class Pipeline {
    /**
     ONLY WORK on vertical, please limit in UI
     */
    func autoStitch(_ items: [StitchItem]) async throws {
        guard items.count >= 2 else {
            print("No autostitch needed")
            return
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
    
    func assetImageToItem(_ asset: PHAsset) throws -> StitchItem {
        return try autoreleasepool { try StitchItem(image: try getUIImage(from: asset), asset: asset) }
    }
    
    func assetVideoToItem(_ asset: PHAsset, progress: @escaping (CGFloat) -> Void) async throws -> StitchItem {
        let video: AVAsset? = await withCheckedContinuation { continuation in
            getAVAsset(asset) { result in
                continuation.resume(returning: result)
            }
        }
        
        guard let video = video else {
            throw MainError.error("Request video failed")
        }
        
        return try await Stitch().stitch(from: video, of: asset, progress: progress)
    }
    
    /**
     USE WHEN PICK FROM PHOTOSUI
     */
    func fixImageForOpenCV(_ image: UIImage) -> UIImage {
        let image = image.resize(size: image.size)

        guard let ciImage = CIImage(image: image),
              let cgImage = CICONTEXT.createCGImage(ciImage, from: ciImage.extent),
              let data = try? UIImage(cgImage: cgImage).jpegData()
        else { return image }

        return UIImage(data: data) ?? image
    }
    
    enum ExportType {
        case small
        case raw(quality: CGFloat)
        case pdf
    }
    
    @PipelineActor
    func export(items: [StitchItem], axis: NSLayoutConstraint.Axis, clean: Bool, type: ExportType, progress: @escaping (CGFloat) -> Void) async throws -> Data {
        var frames = [CGRect]()
        
        for item in items {
            if case .small = type {
                await frames.append(item.process.rect * item.size.aspectFill(to: CGSize(width: THUMB_SIZE, height: THUMB_SIZE)))
            } else {
                await frames.append(item.process.rect * item.size)
            }
        }
        
        guard let minWidth = frames.min(by: { $0.width < $1.width })?.width,
              let minHeight = frames.min(by: { $0.height < $1.height })?.height
        else { throw MainError.error("Estimate size too small") }
        
        let width: CGFloat
        let height: CGFloat
        
        if axis == .horizontal {
            var sumWidth: CGFloat = 0
            
            frames = frames.map { frame in
                let width = frame.width * (minHeight / frame.height)
                let frame = CGRect(x: sumWidth, y: 0, width: width, height: minHeight)
                
                sumWidth += width
                
                return frame
            }
            
            width = sumWidth
            height = minHeight
        } else {
            var sumHeight: CGFloat = 0
            
            frames = frames.map { frame in
                let height = frame.height * (minWidth / frame.width)
                let frame = CGRect(x: 0, y: sumHeight, width: minWidth, height: height)
                
                sumHeight += height
                
                return frame
            }
            
            width = minWidth
            height = sumHeight
        }
        
        let size = CGSize(width: width, height: height)
        
        let image: Data
        
        progress(0)
        
        if case .small = type {
            let format = UIGraphicsImageRendererFormat()
            format.scale = 1
            format.opaque = true
            let renderer = UIGraphicsImageRenderer(size: size, format: format)
            var data = renderer.jpegData(withCompressionQuality: COMPRESSION_QUALITY) { _ in
                for (index, item) in items.enumerated() {
                    if Task.isCancelled { break }
                    
                    autoreleasepool {
                        do {
                            let image = clean ? item.clean : item.image
                            let uiImage = try UIImage.thumbnail(from: image, fillSquareOf: THUMB_SIZE).unwrap()
                            
                            let cropCG = try uiImage.cgImage.unwrap().cropping(to: item.process.rect * uiImage.size).unwrap()
                            
                            if frames.indices.contains(index) {
                                UIImage(cgImage: cropCG).draw(in: frames[index])
                            }
                        } catch {
                            print(error)
                        }
                    }
                    
                    progress(CGFloat(index + 1) / CGFloat(items.count))
                }
            }
            
            data = addScreenshotMetadata(to: data) ?? data
            
            image = data
        } else if case let .raw(quality) = type {
            let format = UIGraphicsImageRendererFormat()
            format.scale = 1
            format.opaque = true
            let renderer = UIGraphicsImageRenderer(size: size, format: format)
            var data = renderer.jpegData(withCompressionQuality: quality) { _ in
                for (index, item) in items.enumerated() {
                    if Task.isCancelled { break }
                    
                    autoreleasepool {
                        do {
                            let image = clean ? item.clean : item.image
                            
                            let cropCG = try UIImage(data: image).unwrap().cgImage.unwrap().cropping(to: item.process.rect * item.size).unwrap()
                            
                            if frames.indices.contains(index) {
                                UIImage(cgImage: cropCG).draw(in: frames[index])
                            }
                        } catch {
                            print(error)
                        }
                    }
                    
                    progress(CGFloat(index + 1) / CGFloat(items.count))
                }
            }
            
            data = addScreenshotMetadata(to: data) ?? data
            
            image = data
        } else {
            let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: size))
            image = renderer.pdfData { context in
                context.beginPage()
                
                for (index, item) in items.enumerated() {
                    if Task.isCancelled { break }
                    
                    autoreleasepool {
                        do {
                            let image = clean ? item.clean : item.image
                            
                            let cropCG = try UIImage(data: image).unwrap().cgImage.unwrap().cropping(to: item.process.rect * item.size).unwrap()
                            
                            if frames.indices.contains(index) {
                                UIImage(cgImage: cropCG).draw(in: frames[index])
                            }
                        } catch {
                            print(error)
                        }
                    }
                    
                    progress(CGFloat(index + 1) / CGFloat(items.count))
                }
            }
        }
        
        try Task.checkCancellation()
        
        return image
    }
    
    private func getUIImage(from asset: PHAsset, size: CGSize = CGSize(width: -1, height: -1), quality: PHImageRequestOptionsDeliveryMode = .highQualityFormat, resizeMode: PHImageRequestOptionsResizeMode = .fast) throws -> UIImage {
        
        var size = size
        if size.width < 0 {
            size = CGSize(width: CGFloat(asset.pixelWidth), height: CGFloat(asset.pixelHeight))
        }
        
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        
        options.deliveryMode = quality
        options.resizeMode = resizeMode
        options.isNetworkAccessAllowed = true
        options.isSynchronous = true
        
        var image: UIImage?

        manager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options, resultHandler: { (result, _) -> Void in
            image = result
        })
        
        guard let image = image else {
            throw MainError.error("Request image failed")
        }
        
        return image
    }
    
    private func getAVAsset(_ asset: PHAsset, deliveryMode: PHVideoRequestOptionsDeliveryMode = .highQualityFormat, completion: @escaping (AVAsset?) -> Void) {
        let option = PHVideoRequestOptions()
        option.deliveryMode = deliveryMode
        option.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestAVAsset(forVideo: asset, options: option) { avAsset, _, _ in
            DispatchQueue.main.async {
                completion(avAsset)
            }
        }
    }
    
    @PipelineActor
    private func addScreenshotMetadata(to data: Data) -> Data? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let type = CGImageSourceGetType(source)
        else { return nil }
        
        let mutableData = NSMutableData()
        
        guard let destination = CGImageDestinationCreateWithData(mutableData, type, 1, nil) else { return nil }
        
        // Tạo Dictionary Metadata cho Exif UserComment
        let exifDictionary: [String: Any] = [
            kCGImagePropertyExifUserComment as String: "Screenshot"
        ]
        
        let metadata: [String: Any] = [
            kCGImagePropertyExifDictionary as String: exifDictionary
        ]
        
        // Thêm ảnh và metadata vào destination
        CGImageDestinationAddImageFromSource(destination, source, 0, metadata as CFDictionary)
        
        if CGImageDestinationFinalize(destination) {
            return mutableData as Data
        }
        
        return nil
    }
}
