//
//  CGOptions.swift
//  AIArtGenerator2.0
//
//  Created by TapUniverse Dev9 on 23/07/2024.
//

import UIKit

extension CGRect {
    init(mid: CGPoint, size: CGSize) {
        self = CGRect(origin: mid - size / 2, size: size)
    }
    
    init(midX: CGFloat, midY: CGFloat, width: CGFloat, height: CGFloat) {
        let mid = CGPoint(x: midX, y: midY)
        let size = CGSize(width: width, height: height)
        
        self = CGRect(origin: mid - size / 2, size: size)
    }
    
    init(origin: CGPoint, maxOrigin: CGPoint) {
        self = CGRect(origin: origin, size: .zero + maxOrigin - origin)
    }
    
    var maxOrigin: CGPoint {
        return CGPoint(x: maxX, y: maxY)
    }
    
    var mid: CGPoint {
        return CGPoint(x: midX, y: midY)
    }

    func relative(to rect: CGRect) -> CGRect {
        return CGRect(x: (minX - rect.minX) / rect.width, y: (minY - rect.minY) / rect.height,
                      width: width / rect.width, height: height / rect.height)
    }
    
    func multiple(by rect: CGRect) -> CGRect {
        let multiple = rect * size
        
        return CGRect(x: minX + multiple.minX, y: minY + multiple.minY, width: multiple.width, height: multiple.height)
    }
    
    func divide(by rect: CGRect) -> CGRect {
        let divider = CGRect(x: 0, y: 0, width: 1, height: 1).relative(to: rect)
        
        return multiple(by: divider)
    }
    
    func divide(by sizeFactory: CGSize) -> CGRect {
        let origin = origin.applying(.init(scaleX: 1 / sizeFactory.width, y: 1 / sizeFactory.height))
        let size = size.applying(.init(scaleX: 1 / sizeFactory.width, y: 1 / sizeFactory.height))
        
        return CGRect(origin: origin, size: size)
    }
    
    func scaleCenter(by scale: CGFloat) -> CGRect {
        let center = CGPoint(x: self.midX, y: self.midY)
        let newWidth = self.width * scale
        let newHeight = self.height * scale
        let newOrigin = CGPoint(
            x: center.x - newWidth / 2,
            y: center.y - newHeight / 2
        )
        return CGRect(origin: newOrigin, size: CGSize(width: newWidth, height: newHeight))
    }
    
    func limit0011() -> CGRect {
        let x1 = min(max(minX, 0), 1)
        let y1 = min(max(minY, 0), 1)
        let x2 = min(max(maxX, 0), 1)
        let y2 = min(max(maxY, 0), 1)
        
        return CGRect(x: x1, y: y1, width: x2 - x1, height: y2 - y1)
    }
    
    /**
     0011 rect only
     */
    func toCIRect() -> CGRect {
        return CGRect(x: minX, y: 1 - maxY, width: width, height: height)
    }
    
    /**
     Inset hoz and vel but not the edges of 0011
     */
    func insetExceptEdges(inset: CGPoint) -> CGRect {
        let minX = minX < .leastNonzeroMagnitude ? minX : (minX + inset.x)
        let minY = minY < .leastNonzeroMagnitude ? minY : (minY + inset.y)
        let maxX = (1 - maxX) < .leastNonzeroMagnitude ? maxX : (maxX - inset.x)
        let maxY = (1 - maxY) < .leastNonzeroMagnitude ? maxY : (maxY - inset.y)
        
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
    /**
     Inset hoz and vel but not the edges of maxRect
     */
    func insetExceptEdges(inset: CGPoint, maxRect: CGRect) -> CGRect {
        let minX = (minX - maxRect.minX) < .leastNonzeroMagnitude ? minX : (minX + inset.x)
        let minY = (minY - maxRect.minY) < .leastNonzeroMagnitude ? minY : (minY + inset.y)
        let maxX = (maxRect.maxY - maxX) < .leastNonzeroMagnitude ? maxX : (maxX - inset.x)
        let maxY = (maxRect.maxY - maxY) < .leastNonzeroMagnitude ? maxY : (maxY - inset.y)
        
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
    /**
     Merge 2 rect
     */
    func merge(with rect: CGRect) -> CGRect {
        let minX = min(minX, rect.minX)
        let maxX = max(maxX, rect.maxX)
        let minY = min(minY, rect.minY)
        let maxY = max(maxY, rect.maxY)
        
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
    func intFrame() -> CGRect {
        return CGRect(x: floor(minX), y: floor(minY), width: ceil(width), height: ceil(height))
    }
    
    func expand(inside rect: CGRect, keepRatio: Bool) -> CGRect {
        let minX = max(minX, rect.minX)
        let maxX = min(maxX, rect.maxX)
        let minY = max(minY, rect.minY)
        let maxY = min(maxY, rect.maxY)
        
        let percent = min((maxX - minX) / width, (maxY - minY) / height)
        
        return CGRect(x: minX, y: minY, width: keepRatio ? width * percent : (maxX - minX), height: keepRatio ? height * percent : (maxY - minY))
    }

    func coverRotated(at angle: CGFloat) -> CGRect {
        let points = [
            CGPoint(x: minX, y: minY),
            CGPoint(x: maxX, y: minY),
            CGPoint(x: minX, y: maxY),
            CGPoint(x: maxX, y: maxY)
        ].map { point -> CGPoint in
            let expect = (point - mid).applying(.init(rotationAngle: angle)) + mid
            
            return expect
        }
        
        let xs = points.map { $0.x }
        let ys = points.map { $0.y }
        
        return CGRect(x: xs.min() ?? 0, y: ys.min() ?? 0, width: (xs.max() ?? 0) - (xs.min() ?? 0), height: (ys.max() ?? 0) - (ys.min() ?? 0))
    }
    
    func smoothRect(to rect: CGRect, inner: CGRect, smoothMid: CGFloat = 0.2, smoothSize: CGFloat = 0.2) -> CGRect {
        let p1 = mid // current position
        let p2 = rect.mid // target position
        let s1 = size // current scale
        let s2 = rect.size // target scale
        
        let p = p1 + (p2 - p1) * min(1, smoothMid)
        let s = s1 + (s2 - s1) * min(1, smoothSize)
        
        var smoothRect = CGRect(origin: p - s / 2.0, size: s)
        
        var tranX = CGFloat(0)
        var tranY = CGFloat(0)

        if smoothRect.minX > inner.minX {
            tranX = inner.minX - smoothRect.minX
        }
        
        if smoothRect.maxX < inner.maxX {
            if tranX > 0 {
                let minX = min(inner.minX, smoothRect.minX)
                let maxX = min(inner.maxX, smoothRect.maxX)
                
                smoothRect = .init(x: minX, y: smoothRect.minY, width: maxX, height: smoothRect.maxY)
            } else {
                tranX = inner.maxX - smoothRect.maxX
                
                smoothRect = smoothRect.applying(.init(translationX: tranX, y: 0))
            }
            
            tranX = 0
        }
        
        if smoothRect.minY > inner.minY {
            tranY = inner.minY - smoothRect.minY
        }
        
        if smoothRect.maxY < inner.maxY {
            if tranY > 0 {
                let minY = min(inner.minY, smoothRect.minY)
                let maxY = min(inner.maxY, smoothRect.maxY)
                
                smoothRect = .init(x: smoothRect.minX, y: minY, width: smoothRect.maxX, height: maxY)
            } else {
                tranY = inner.maxY - smoothRect.maxY
                
                smoothRect = smoothRect.applying(.init(translationX: 0, y: tranY))
            }
            
            tranY = 0
        }
        
        smoothRect = smoothRect.applying(.init(translationX: tranX, y: tranY))
        
        return smoothRect
    }
    
    func abs() -> CGRect {
        return CGRect(x: Swift.abs(minX), y: Swift.abs(minY), width: Swift.abs(width), height: Swift.abs(height))
    }
}

extension CGPoint {
    func angle(to point: CGPoint) -> CGFloat {
        let angle = atan2(y, x) - atan2(point.y, point.x)
        
        return angle
    }
    
    func length() -> CGFloat {
        return sqrt(x * x + y * y)
    }
    
    func length(to point: CGPoint) -> CGFloat {
        let x = point.x - x
        let y = point.y - y
        
        return sqrt(x * x + y * y)
    }

    func vec01() -> CGPoint {
        return CGPoint(x: x / Swift.abs(x), y: y / Swift.abs(y))
    }
    
    func rotate(by angle: CGFloat, with anchor: CGPoint) -> CGPoint {
        return (self - anchor).applying(.init(rotationAngle: angle)) + anchor
    }

    func abs() -> CGPoint {
        return CGPoint(x: Swift.abs(x), y: Swift.abs(y))
    }
}

extension CGSize {
    func wxh() -> CGFloat {
        return width * height
    }
    
    func wh() -> CGFloat {
        return width + height
    }
    
    func aspectFit(to size: CGSize) -> CGSize {
        let scale = min(size.width / width, size.height / height)
        return CGSize(width: width * scale, height: height * scale)
    }
    
    func aspectFill(to size: CGSize) -> CGSize {
        let scale = max(size.width / width, size.height / height)
        return CGSize(width: width * scale, height: height * scale)
    }
    
    func intSize() -> CGSize {
        return CGSize(width: ceil(width), height: ceil(height))
    }

    func aspectFit(to rect: CGRect) -> CGRect {
        let scale = min(rect.width / width, rect.height / height)
        let size = CGSize(width: width * scale, height: height * scale)
        
        return CGRect(x: rect.midX - size.width / 2, y: rect.midY - size.height / 2, width: size.width, height: size.height)
    }
    
    func aspectFill(to rect: CGRect) -> CGRect {
        let scale = max(rect.width / width, rect.height / height)
        let size = CGSize(width: width * scale, height: height * scale)
        
        return CGRect(x: rect.midX - size.width / 2, y: rect.midY - size.height / 2, width: size.width, height: size.height)
    }
    
    func expand(minSize: CGSize, keepRatio: Bool) -> CGSize {
        var width = width
        var height = height
        
        if width < 0 || height < 0 {
            width = width / height
            height = 1
        }
        
        if keepRatio {
            if width <= minSize.width || height <= minSize.height {
                let percent = max(minSize.width / width, minSize.height / height)
                return CGSize(width: width * percent, height: height * percent)
            }
            
            return self
        } else {
            // If not keeping aspect ratio, simply use the maximum of current and minimum sizes
            let newWidth = max(width, minSize.width)
            let newHeight = max(height, minSize.height)
            
            return CGSize(width: newWidth, height: newHeight)
        }
    }
    
    func expand(maxSize: CGSize, keepRatio: Bool) -> CGSize {
        var width = width
        var height = height
        
        if width < 0 || height < 0 {
            width = width / height
            height = 1
        }
        
        if keepRatio {
            if width >= maxSize.width || height >= maxSize.height {
                let percent = min(maxSize.width / width, maxSize.height / height)
                return CGSize(width: width * percent, height: height * percent)
            }
            
            return self
        } else {
            // If not keeping aspect ratio, simply use the maximum of current and minimum sizes
            let newWidth = min(width, maxSize.width)
            let newHeight = min(height, maxSize.height)
            
            return CGSize(width: newWidth, height: newHeight)
        }
    }
    
    func abs() -> CGSize {
        return CGSize(width: Swift.abs(width), height: Swift.abs(height))
    }
}

extension CGRect {
    func closestPoint(to centerVec: CGPoint, rotation: CGFloat) -> CGPoint? {
        // Get the rotated rectangle’s corner points
        let rectPoints = rotatedRectPoints(rotation: rotation)
        
        // Get the midpoints of rectangle edges
        let midpoints = [
            midpoint(rectPoints[0], rectPoints[1]),
            midpoint(rectPoints[1], rectPoints[2]),
            midpoint(rectPoints[2], rectPoints[3]),
            midpoint(rectPoints[3], rectPoints[0])
        ]
        
        // Combine corners and midpoints
        let candidatePoints = rectPoints + midpoints
        
        // Find the closest point to the line segment
        return candidatePoints.min(by: { distanceFromPoint($0, to: centerVec) < distanceFromPoint($1, to: centerVec) })
    }

    // Function to calculate the corners of a rotated rectangle
    private func rotatedRectPoints(rotation: CGFloat) -> [CGPoint] {
        let halfWidth = size.width / 2
        let halfHeight = size.height / 2

        let corners = [
            CGPoint(x: -halfWidth, y: -halfHeight),
            CGPoint(x: halfWidth, y: -halfHeight),
            CGPoint(x: halfWidth, y: halfHeight),
            CGPoint(x: -halfWidth, y: halfHeight)
        ]

        return corners.map { rotatePoint($0, around: CGPoint(x: midX, y: midY), by: rotation) }
    }

    // Function to rotate a point around a center
    private func rotatePoint(_ point: CGPoint, around center: CGPoint, by rotation: CGFloat) -> CGPoint {
        let cosA = cos(rotation)
        let sinA = sin(rotation)
        let x = point.x * cosA - point.y * sinA + center.x
        let y = point.x * sinA + point.y * cosA + center.y
        return CGPoint(x: x, y: y)
    }

    // Function to compute the midpoint of two points
    private func midpoint(_ p1: CGPoint, _ p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
    }

    // Function to compute the shortest distance from a point to a line segment
    private func distanceFromPoint(_ point: CGPoint, to centerVec: CGPoint) -> CGFloat {
        let (p1, p2) = (mid, mid + centerVec)
        let lineLengthSquared = pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2)
        
        if lineLengthSquared == 0 { return hypot(point.x - p1.x, point.y - p1.y) } // Line is a point

        let t = max(0, min(1, ((point.x - p1.x) * (p2.x - p1.x) + (point.y - p1.y) * (p2.y - p1.y)) / lineLengthSquared))
        let projection = CGPoint(x: p1.x + t * (p2.x - p1.x), y: p1.y + t * (p2.y - p1.y))

        return hypot(point.x - projection.x, point.y - projection.y)
    }

}

// Operation
precedencegroup CGRectOperation {
    assignment: true
}

infix operator ++: CGRectOperation
infix operator *+: CGRectOperation
infix operator --: CGRectOperation
infix operator *-: CGRectOperation
infix operator -->: CGRectOperation
infix operator &+: CGRectOperation
infix operator +*: CGRectOperation

extension CGRect {
    static func &+ (lhs: CGRect, rhs: CGRect) -> CGRect {
        let minX = min(lhs.minX, rhs.minX)
        let maxX = max(lhs.maxX, rhs.maxX)
        let minY = min(lhs.minY, rhs.minY)
        let maxY = max(lhs.maxY, rhs.maxY)
        
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
    static func + (lhs: CGRect, rhs: CGRect) -> CGRect {
        return CGRect(x: lhs.minX + rhs.minX, y: lhs.minY + rhs.minY, width: lhs.maxX + rhs.maxX, height: lhs.maxY + rhs.maxY)
    }
    
    static func + (lhs: CGRect, size: CGSize) -> CGRect {
        let size = lhs.size.applying(.init(translationX: size.width, y: size.height))
        
        return CGRect(origin: lhs.origin, size: size)
    }
    
    static func + (lhs: CGRect, point: CGPoint) -> CGRect {
        let origin = lhs.origin.applying(.init(translationX: point.x, y: point.y))
        
        return CGRect(origin: origin, size: lhs.size)
    }
    
    static func - (lhs: CGRect, rhs: CGRect) -> CGRect {
        return CGRect(x: lhs.minX - rhs.minX, y: lhs.minY - rhs.minY, width: lhs.maxX - rhs.maxX, height: lhs.maxY - rhs.maxY)
    }
    
    static func - (lhs: CGRect, size: CGSize) -> CGRect {
        var size = lhs.size.applying(.init(translationX: -size.width, y: -size.height))
        size = .init(width: max(0, size.width), height: max(0, size.height))
        
        return CGRect(origin: lhs.origin, size: size)
    }
    
    static func - (lhs: CGRect, point: CGPoint) -> CGRect {
        let origin = lhs.origin.applying(.init(translationX: -point.x, y: -point.y))
        
        return CGRect(origin: origin, size: lhs.size)
    }
    
    static func * (lhs: CGRect, rhs: CGRect) -> CGRect {
        return CGRect(x: lhs.minX * rhs.minX, y: lhs.minY * rhs.minY, width: lhs.maxX * rhs.maxX, height: lhs.maxY * rhs.maxY)
    }
    
    static func * (lhs: CGRect, scale: CGSize) -> CGRect {
        let origin = lhs.origin.applying(.init(scaleX: scale.width, y: scale.height))
        let size = lhs.size.applying(.init(scaleX: scale.width, y: scale.height))
        
        return CGRect(origin: origin, size: size)
    }
    
    static func * (lhs: CGRect, scale: CGFloat) -> CGRect {
        let origin = lhs.origin.applying(.init(scaleX: scale, y: scale))
        let size = lhs.size.applying(.init(scaleX: scale, y: scale))
        
        return CGRect(origin: origin, size: size)
    }
    
    static func / (lhs: CGRect, scale: CGSize) -> CGRect {
        if scale.width == 0 || scale.height == 0 { return lhs }
        
        let origin = lhs.origin.applying(.init(scaleX: 1 / scale.width, y: 1 / scale.height))
        let size = lhs.size.applying(.init(scaleX: 1 / scale.width, y: 1 / scale.height))
        
        return CGRect(origin: origin, size: size)
    }
    
    static func / (lhs: CGRect, scale: CGFloat) -> CGRect {
        if scale == 0 { return lhs }
        
        let origin = lhs.origin.applying(.init(scaleX: 1 / scale, y: 1 / scale))
        let size = lhs.size.applying(.init(scaleX: 1 / scale, y: 1 / scale))
        
        return CGRect(origin: origin, size: size)
    }
    
    static func --> (lhs: CGRect, rhs: CGRect) -> CGRect {
        return CGRect(x: (lhs.minX - rhs.minX) / rhs.width, y: (lhs.minY - rhs.minY) / rhs.height,
                      width: lhs.width / rhs.width, height: lhs.height / rhs.height)
    }
    
    static func +* (lhs: CGRect, rhs: CGRect) -> CGRect {
        let multiple = rhs * lhs.size
        
        return CGRect(x: lhs.minX + multiple.minX, y: lhs.minY + multiple.minY, width: multiple.width, height: multiple.height)
    }
    
    static func *+ (lhs: CGRect, bonus: CGFloat) -> CGRect {
        let newRect = lhs.insetBy(dx: -lhs.width * bonus, dy: -lhs.height * bonus)
        
        // Calculate new min and max coordinates
        let newMinX = max(newRect.minX, 0)
        let newMinY = max(newRect.minY, 0)
        let newMaxX = min(newRect.maxX, 1)
        let newMaxY = min(newRect.maxY, 1)
        
        return CGRect(x: newMinX, y: newMinY, width: newMaxX - newMinX, height: newMaxY - newMinY)
    }
    
    static func ++ (lhs: CGRect, bonus: CGFloat) -> CGRect {
        let newRect = lhs.insetBy(dx: -bonus, dy: -bonus)
        
        // Calculate new min and max coordinates
        let newMinX = max(newRect.minX, 0)
        let newMinY = max(newRect.minY, 0)
        let newMaxX = min(newRect.maxX, 1)
        let newMaxY = min(newRect.maxY, 1)
        
        return CGRect(x: newMinX, y: newMinY, width: newMaxX - newMinX, height: newMaxY - newMinY)
    }
    
    static func *- (lhs: CGRect, minus: CGFloat) -> CGRect {
        let newRect = lhs.insetBy(dx: lhs.width * minus, dy: lhs.height * minus)
        
        // Calculate new min and max coordinates
        let newMinX = max(newRect.minX, 0)
        let newMinY = max(newRect.minY, 0)
        let newMaxX = min(newRect.maxX, 1)
        let newMaxY = min(newRect.maxY, 1)
        
        return CGRect(x: newMinX, y: newMinY, width: newMaxX - newMinX, height: newMaxY - newMinY)
    }
    
    static func -- (lhs: CGRect, minus: CGFloat) -> CGRect {
        let newRect = lhs.insetBy(dx: minus, dy: minus)
        
        // Calculate new min and max coordinates
        let newMinX = max(newRect.minX, 0)
        let newMinY = max(newRect.minY, 0)
        let newMaxX = min(newRect.maxX, 1)
        let newMaxY = min(newRect.maxY, 1)
        
        return CGRect(x: newMinX, y: newMinY, width: newMaxX - newMinX, height: newMaxY - newMinY)
    }
}

extension CGPoint {
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func + (lhs: CGPoint, rhs: CGSize) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.width, y: lhs.y + rhs.height)
    }
    
    static func + (lhs: CGPoint, value: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x + value, y: lhs.y + value)
    }
    
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    static func - (lhs: CGPoint, rhs: CGSize) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.width, y: lhs.y - rhs.height)
    }
    
    static func - (lhs: CGPoint, value: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x - value, y: lhs.y - value)
    }
    
    static func * (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
    }
    
    static func * (lhs: CGPoint, rhs: CGSize) -> CGPoint {
        return CGPoint(x: lhs.x * rhs.width, y: lhs.y * rhs.height)
    }
    
    static func * (lhs: CGPoint, value: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x * value, y: lhs.y * value)
    }
    
    static func / (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x / rhs.x, y: lhs.y / rhs.y)
    }
    
    static func / (lhs: CGPoint, rhs: CGSize) -> CGPoint {
        return CGPoint(x: lhs.x / rhs.width, y: lhs.y / rhs.height)
    }
    
    static func / (lhs: CGPoint, value: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x / value, y: lhs.y / value)
    }
}

extension CGSize {
    static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    
    static func + (lhs: CGSize, rhs: CGPoint) -> CGSize {
        return CGSize(width: lhs.width + rhs.x, height: lhs.height + rhs.y)
    }
    
    static func + (lhs: CGSize, value: CGFloat) -> CGSize {
        return CGSize(width: lhs.width + value, height: lhs.height + value)
    }
    
    static func - (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
    
    static func - (lhs: CGSize, rhs: CGPoint) -> CGSize {
        return CGSize(width: lhs.width - rhs.x, height: lhs.height - rhs.y)
    }
    
    static func - (lhs: CGSize, value: CGFloat) -> CGSize {
        return CGSize(width: lhs.width - value, height: lhs.height - value)
    }
    
    static func * (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width * rhs.width, height: lhs.height * rhs.height)
    }
    
    static func * (lhs: CGSize, rhs: CGPoint) -> CGSize {
        return CGSize(width: lhs.width * rhs.x, height: lhs.height * rhs.y)
    }
    
    static func * (lhs: CGSize, value: CGFloat) -> CGSize {
        return CGSize(width: lhs.width * value, height: lhs.height * value)
    }
    
    static func / (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width / rhs.width, height: lhs.height / rhs.height)
    }
    
    static func / (lhs: CGSize, rhs: CGPoint) -> CGSize {
        return CGSize(width: lhs.width / rhs.x, height: lhs.height / rhs.y)
    }
    
    static func / (lhs: CGSize, value: CGFloat) -> CGSize {
        return CGSize(width: lhs.width / value, height: lhs.height / value)
    }
}
