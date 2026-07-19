//
//  CGImageCreateOptions.swift
//  RemoveObject2.0
//
//  Created by Tap Dev5 on 17/05/2023.
//

import UIKit

extension UIImage {
    func rgbColorSpaceImage() -> UIImage? {
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue)
        let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        context.draw(cgImage!, in: CGRect(origin: CGPoint.zero, size: size))

        let imgRef = context.makeImage()
        return UIImage(cgImage: imgRef!)
    }
    
    static func thumbnail(from data: Data, fillSquareOf side: CGFloat) -> UIImage? {
        let source = CGImageSourceCreateWithData(data as CFData, nil)
        guard let source else { return nil }

        // Read pixel dimensions to size the thumbnail for aspect-FILL.
        var maxPixel = side
        if let props = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
           let w = props[kCGImagePropertyPixelWidth] as? CGFloat,
           let h = props[kCGImagePropertyPixelHeight] as? CGFloat,
           min(w, h) > 0 {
            // Scale so the SHORTER side == side, so the longer side covers the box.
            let scale = side / min(w, h)
            maxPixel = max(w, h) * scale
        }

        return thumbnail(from: data, maxPixel: maxPixel)
    }

    /**
     Decode at most `maxPixel` on the longer side (never upscales past native),
     with EXIF orientation baked into the pixels.
     */
    static func thumbnail(from data: Data, maxPixel: CGFloat) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }

        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,   // respect EXIF orientation
            kCGImageSourceShouldCacheImmediately: true,         // decode now, off the main thread ideally
            kCGImageSourceThumbnailMaxPixelSize: maxPixel
        ]

        guard let cg = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            return nil
        }
        return UIImage(cgImage: cg)
    }
}
