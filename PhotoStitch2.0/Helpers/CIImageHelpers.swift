//
//  CIImageCreateOptions.swift
//  BackgroundEraser2.0
//
//  Created by Tap Dev5 on 13/04/2023.
//

import UIKit

extension CIImage {

    static func createCustomCIImageColor(color: UIColor) -> CIImage? {
        // Convert UIColor to CIColor
        let ciColor = CIColor(color: color)

        // Create CIFilter for a solid color
        guard let colorFilter = CIFilter(name: "CIConstantColorGenerator") else { return nil }

        // Set the color for the filter
        colorFilter.setValue(ciColor, forKey: "inputColor")

        // Create a CIImage from the filter
        let ciImage = colorFilter.outputImage

        return ciImage
    }
    
    func correctOrientation(preferredTransform: CGAffineTransform) -> CIImage {
        let ciImage = transformed(by: .init(scaleX: 1, y: -1).concatenating(preferredTransform).concatenating(.init(scaleX: 1, y: -1)))
        return ciImage.transformed(by: .init(translationX: -ciImage.extent.minX, y: -ciImage.extent.minY))
    }
    
    func outline() -> CIImage? {
        let ciSeg = self
            .composited(over: CIImage(color: .black).cropped(to: self.extent))
            .clampedToExtent()
            .applyingGaussianBlur(sigma: 2)
            .cropped(to: self.extent)
        
        let ciThresh = ciSeg.applyingFilter("CIColorThreshold", parameters: [
            "inputThreshold": 0.6
        ]).applyingFilter("CIMaskToAlpha")
        
        let ciThresh2 = ciSeg.applyingFilter("CIColorThreshold", parameters: [
            "inputThreshold": 0.25
        ]).applyingFilter("CIMaskToAlpha")
        
        var ciOutline = ciThresh2
            .applyingFilter("CISourceOutCompositing", parameters: [
                kCIInputBackgroundImageKey: ciThresh
            ])
        
        ciOutline = ciOutline
            .composited(over: .black.cropped(to: ciOutline.extent))
            .clampedToExtent()
            .applyingGaussianBlur(sigma: 1)
            .applyingFilter("CIColorThreshold", parameters: [
                "inputThreshold": 0.01
            ])
            .cropped(to: ciOutline.extent)
            .applyingFilter("CIMaskToAlpha")
        
        if let ciFill = CIImage.createCustomCIImageColor(color: UIColor(white: 1, alpha: 0.2))?
            .applyingFilter("CISourceInCompositing", parameters: [
                kCIInputBackgroundImageKey: ciThresh
            ]).cropped(to: ciSeg.extent),
           let ciGlow = CIImage.createCustomCIImageColor(color: UIColor(white: 1, alpha: 0.8))?
            .applyingFilter("CISourceInCompositing", parameters: [
                kCIInputBackgroundImageKey: ciOutline
                    .composited(over: .black.cropped(to: ciOutline.extent))
                    .clampedToExtent()
                    .applyingGaussianBlur(sigma: 3)
                    .applyingFilter("CIColorThreshold", parameters: [
                        "inputThreshold": 0.01
                    ])
                    .applyingGaussianBlur(sigma: 10)
                    .cropped(to: ciSeg.extent)
                    .applyingFilter("CIMaskToAlpha")
                    .applyingFilter("CISourceOutCompositing", parameters: [
                        kCIInputBackgroundImageKey: ciThresh
                    ])
            ]),
           let ciFinal = CIImage.createCustomCIImageColor(color: .red)?
            .applyingFilter("CISourceInCompositing", parameters: [
                kCIInputBackgroundImageKey: ciOutline
            ]).cropped(to: ciSeg.extent)
            .composited(over: ciFill)
            .composited(over: ciGlow) {
            
            return ciFinal
        }
        
        return nil
    }
    
    func getAverageAlpha() -> CGFloat? {
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
    
    /**
     frame which have alpha in 0011
     */
    func autoCrop() -> CGRect {
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
}
