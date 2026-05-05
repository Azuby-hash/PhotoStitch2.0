//
//  UIImageCorrectOrientation.swift
//  BlurPhoto
//
//  Created by Tap Dev5 on 07/07/2022.
//

import UIKit

extension UIImage {

    public func correctlyOrientedImage() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }

        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let normalizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage();
        UIGraphicsEndImageContext();

        return normalizedImage;
    }

    static func emptyImage(size: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        let renderer = UIGraphicsImageRenderer(size: size.__intSize(), format: format)
        
        return renderer.image { _ in }
    }
    
    static func imageColor(size: CGSize, color: UIColor) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        let renderer = UIGraphicsImageRenderer(size: size.__intSize(), format: format)
        
        return renderer.image { context in
            context.cgContext.setFillColor(color.cgColor)
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
    
    public func withRoundedCorners(radius: CGFloat? = nil) -> UIImage? {
        let maxRadius = min(size.width, size.height) / 2
        let cornerRadius: CGFloat
        if let radius = radius, radius > 0 && radius <= maxRadius {
            cornerRadius = radius
        } else {
            cornerRadius = maxRadius
        }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let rect = CGRect(origin: .zero, size: size)
        UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
        draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    func getAverageAlpha() -> CGFloat? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull as Any])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return CGFloat(bitmap[3]) / 255
    }
    
    static func intermasks(_ m1: (image: UIImage?, frame: CGRect),
                           _ m2: (image: UIImage?, frame: CGRect)) -> (inter: Bool, image: UIImage?) {
        if !m1.frame.insetBy(dx: m1.frame.width / 4, dy: m1.frame.height / 4).intersects(m2.frame) {
            return (false, nil)
        }
        
        guard let m1Image = m1.image,
              let m2Image = m2.image,
              let ciImage1 = CIImage(image: m1Image) ?? m1Image.ciImage,
              let ciImage2 = CIImage(image: m2Image) ?? m2Image.ciImage
        else { return (false, nil) }
        
        let ciImage1Tran = ciImage1
            .transformed(by: .init(scaleX: m1.frame.width / ciImage1.extent.width,
                                   y: m1.frame.height / ciImage1.extent.height))
        let ciImage2Tran = ciImage2
            .transformed(by: .init(scaleX: m2.frame.width / ciImage2.extent.width,
                                   y: m2.frame.height / ciImage2.extent.height))
            .transformed(by: .init(translationX: m2.frame.minX - m1.frame.minX,
                                   y: m1.frame.maxY - m2.frame.maxY))
        
        let ciInter = ciImage2Tran
            .applyingFilter("CISourceInCompositing", parameters: [
                kCIInputBackgroundImageKey: ciImage1Tran
            ])
        let ciOuter = ciImage2Tran
            .applyingFilter("CISourceOverCompositing", parameters: [
                kCIInputBackgroundImageKey: ciImage1Tran
            ])
        
        let averageInter = ciInter.__getAverageAlpha() ?? 0
        let averageOuter = ciOuter.__getAverageAlpha() ?? 0.000001
        
        if averageInter / averageOuter > 0.005 {
            guard let cgImage = CIContext().createCGImage(ciOuter, from: ciOuter.extent) else {
                return (true, nil)
            }
            
            return (true, UIImage(cgImage: cgImage))
        }
        
        return (false, nil)
    }
}

extension UIImage {
    func resize(size: CGSize, isAspectFill: Bool = true) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        let size = size
        let scale = (isAspectFill ? max : min)(size.width / self.size.width, size.height / self.size.height)
        let resize = self.size.applying(.init(scaleX: scale, y: scale)).__intSize()

        let renderer = UIGraphicsImageRenderer(size: resize.__intSize(), format: format)
        
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: resize).__intFrame())
        }
    }
    
    func resizeStretch(size: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        let renderer = UIGraphicsImageRenderer(size: size.__intSize(), format: format)
        
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size).__intFrame())
        }
    }
    
    func cropTo(frame: CGRect, scale: CGFloat = 1, fill: UIColor? = nil) -> UIImage {
        let frame = frame.__intFrame()
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        
        let renderer = UIGraphicsImageRenderer(size: frame.size, format: format)
        
        return renderer.image { ctx in
            if let fill = fill {
                ctx.cgContext.setFillColor(fill.cgColor)
                ctx.cgContext.fill([CGRect(origin: .zero, size: frame.size)])
            }
            self.draw(in: CGRect(origin: frame.origin.applying(.init(scaleX: -1, y: -1)), size: size))
        }
    }
    
    /**
     frame: 0011
     */
    func specCrop(rect: CGRect, spec: CGFloat, specMode: UIImageView.ContentMode, scale: CGFloat = 1, fill: UIColor? = nil) -> (originSize: CGSize, croppedImage: UIImage) {
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        
        var rect = rect
        rect.origin = rect.origin.applying(.init(scaleX: size.width, y: size.height))
        rect.size = rect.size.applying(.init(scaleX: size.width, y: size.height))
        
        let percent = (specMode == .scaleAspectFill ? max : min)(spec / rect.size.width, spec / rect.size.height)
        rect.origin = rect.origin.applying(.init(scaleX: percent, y: percent))
        rect.size = rect.size.applying(.init(scaleX: percent, y: percent)).__intSize()
        
        let originSize = size.applying(.init(scaleX: percent, y: percent)).__intSize()
        let renderer = UIGraphicsImageRenderer(size: rect.size, format: format)
        
        return (originSize, renderer.image { ctx in
            if let fill = fill {
                ctx.cgContext.setFillColor(fill.cgColor)
                ctx.cgContext.fill([CGRect(origin: .zero, size: rect.size)])
            }
            draw(in: CGRect(origin: rect.origin.applying(.init(scaleX: -1, y: -1)), size: originSize))
        })
    }
    
    /**
     frame which have alpha in 0011
     */
    func autoCrop() -> CGRect {
        guard let ciImage = CIImage(image: self) ?? ciImage else { return .zero }
        
        return ciImage.__autoCrop()
    }
}

extension CIImage {
    /**
     frame which have alpha in 0011
     */
    fileprivate func __autoCrop() -> CGRect {
        let ciRow = applyingFilter("CIRowAverage", parameters: [ kCIInputExtentKey: CIVector(cgRect: extent) ])
        let ciColumn = applyingFilter("CIColumnAverage", parameters: [ kCIInputExtentKey: CIVector(cgRect: extent) ])
        
        let context = CIContext()
        
        func array(_ ci: CIImage) -> [Float] {
            let rowBytes = 4 * Int(ci.extent.width) // 4 channels (RGBA) of 8-bit data
            let dataSize = rowBytes * Int(ci.extent.height)
            
            var row = [Float](repeating: 0, count: dataSize)
            
            context.render(ci, toBitmap: &row, rowBytes: rowBytes * 4, bounds: ci.extent, format: .RGBAf, colorSpace: nil)
            
            row = row.enumerated().filter { e in
                return e.offset % 4 == 3
            }.map { e in
                return e.element * 255
            }
            
            for _ in 0..<5 {
                row.removeFirst()
                row.removeLast()
            }
            
            return row
        }
        
        let row = array(ciRow) // y
        let column = array(ciColumn) // x
        
        var minX = 0
        var minY = 0
        var maxX = column.count - 1
        var maxY = row.count - 1
        
        var didMinY = false
        for bit in row.enumerated() {
            if bit.element > 0 {
                minY = bit.offset
                didMinY = true
                break
            }
        }
        if !didMinY {
            minY = row.count - 1
        }
        
        for bit in row.enumerated().reversed() {
            if bit.element > 0 {
                maxY = bit.offset
                break
            }
        }
        
        for bit in column.enumerated() {
            if bit.element > 0 {
                minX = bit.offset
                break
            }
        }
        
        var didMaxX = false
        for bit in column.enumerated().reversed() {
            if bit.element > 0 {
                maxX = bit.offset
                didMaxX = true
                break
            }
        }
        if !didMaxX {
            maxX = 0
        }
        
        return CGRect(x: CGFloat(minX) / CGFloat(column.count - 1), y: CGFloat(row.count - maxY - 1) / CGFloat(row.count - 1),
                      width: CGFloat(maxX - minX) / CGFloat(column.count - 1), height: CGFloat(maxY - minY) / CGFloat(row.count - 1))
    }

    fileprivate func __getAverageAlpha() -> CGFloat? {
        let extentVector = CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [
            kCIInputImageKey: self,
            kCIInputExtentKey: extentVector])
        else { return nil }
        
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull as Any])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return CGFloat(bitmap[3]) / 255
    }
}

extension CGSize {
    fileprivate func __intSize() -> CGSize {
        return CGSize(width: ceil(width), height: ceil(height))
    }
}

extension CGRect {
    fileprivate func __intFrame() -> CGRect {
        return CGRect(x: floor(minX), y: floor(minY), width: ceil(width), height: ceil(height))
    }
}
