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
}
