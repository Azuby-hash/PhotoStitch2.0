//
//  Support.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 6/25/26.
//

import SwiftUI
import UIKit

let CICONTEXT = CIContext()
var EMPTY_DATA: Data {
    get throws {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1), format: format)
        return try renderer.image { c in
            c.cgContext.setFillColor(UIColor.clear.cgColor)
            c.cgContext.fill(CGRect(origin: .zero, size: CGSize(width: 1, height: 1)))
        }.pngData().unwrap()
    }
}

extension UIImage {
    func jpegData() throws -> Data {
        return try jpegData(compressionQuality: 0.8).unwrap()
    }
    
    func processClean() throws -> Data {
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let mask = renderer.image { context in
            context.cgContext.setFillColor(UIColor.black.cgColor)
            context.cgContext.fill(CGRect(origin: .zero, size: size))
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fill(CGRect(x: size.width - SCROLL_REMOVE, y: 0, width: SCROLL_REMOVE, height: size.height))
        }
        
        let output = OpenCVWrapper.inpaint(image: self, mask: mask, radius: 0.0)
        
        return try output.jpegData()
    }
}

extension Data {
    func getThumbnail(originSize: CGSize) throws -> UIImage {
        let size = (originSize.height > 0 && originSize.width > 0) ? (Swift.max(originSize.width, originSize.height) * 100 / Swift.min(originSize.width, originSize.height)) : 100
        
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: size,
            kCGImageSourceShouldCacheImmediately: true
        ]
        
        guard let source = CGImageSourceCreateWithData(self as CFData, nil),
              let thumbnail = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary)
        else { throw MainError.error("Can't get thumbnail") }
        
        return UIImage(cgImage: thumbnail)
    }
}
