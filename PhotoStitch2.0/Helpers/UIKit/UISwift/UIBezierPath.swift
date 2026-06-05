//
//  UIBezierPath.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 6/5/26.
//

import UIKit

extension UIBezierPath {
    
    @discardableResult
    func ecgPath(_ cgPath: CGPath) -> Self {
        self.cgPath = cgPath
        return self
    }
    
    @discardableResult
    func emove(to point: CGPoint) -> Self {
        self.move(to: point)
        return self
    }
    
    @discardableResult
    func eaddLine(to point: CGPoint) -> Self {
        self.addLine(to: point)
        return self
    }
    
    @discardableResult
    func eaddCurve(to endPoint: CGPoint, controlPoint1: CGPoint, controlPoint2: CGPoint) -> Self {
        self.addCurve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        return self
    }
    
    @discardableResult
    func eaddQuadCurve(to endPoint: CGPoint, controlPoint: CGPoint) -> Self {
        self.addQuadCurve(to: endPoint, controlPoint: controlPoint)
        return self
    }
    
    @discardableResult
    func eaddArc(withCenter center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool) -> Self {
        self.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
        return self
    }
    
    @discardableResult
    func eclose() -> Self {
        self.close()
        return self
    }
    
    @discardableResult
    func eremoveAllPoints() -> Self {
        self.removeAllPoints()
        return self
    }
    
    @discardableResult
    func eappend(_ bezierPath: UIBezierPath) -> Self {
        self.append(bezierPath)
        return self
    }
    
    @discardableResult
    func eapply(_ transform: CGAffineTransform) -> Self {
        self.apply(transform)
        return self
    }
    
    @discardableResult
    func elineWidth(_ lineWidth: CGFloat) -> Self {
        self.lineWidth = lineWidth
        return self
    }
    
    @discardableResult
    func elineCapStyle(_ lineCapStyle: CGLineCap) -> Self {
        self.lineCapStyle = lineCapStyle
        return self
    }
    
    @discardableResult
    func elineJoinStyle(_ lineJoinStyle: CGLineJoin) -> Self {
        self.lineJoinStyle = lineJoinStyle
        return self
    }
    
    @discardableResult
    func emiterLimit(_ miterLimit: CGFloat) -> Self {
        self.miterLimit = miterLimit
        return self
    }
    
    @discardableResult
    func eflatness(_ flatness: CGFloat) -> Self {
        self.flatness = flatness
        return self
    }
    
    @discardableResult
    func eusesEvenOddFillRule(_ usesEvenOddFillRule: Bool) -> Self {
        self.usesEvenOddFillRule = usesEvenOddFillRule
        return self
    }
    
    @discardableResult
    func esetLineDash(_ pattern: UnsafePointer<CGFloat>?, count: Int, phase: CGFloat) -> Self {
        self.setLineDash(pattern, count: count, phase: phase)
        return self
    }
    
    @discardableResult
    func efill() -> Self {
        self.fill()
        return self
    }
    
    @discardableResult
    func estroke() -> Self {
        self.stroke()
        return self
    }
    
    @discardableResult
    func efill(with blendMode: CGBlendMode, alpha: CGFloat) -> Self {
        self.fill(with: blendMode, alpha: alpha)
        return self
    }
    
    @discardableResult
    func estroke(with blendMode: CGBlendMode, alpha: CGFloat) -> Self {
        self.stroke(with: blendMode, alpha: alpha)
        return self
    }
    
    @discardableResult
    func eaddClip() -> Self {
        self.addClip()
        return self
    }
}


extension CGMutablePath {
    @discardableResult
    func eaddQuadCurve(to endPoint: CGPoint, control: CGPoint, transform: CGAffineTransform = .identity) -> Self {
        self.addQuadCurve(to: endPoint, control: control, transform: transform)
        return self
    }
    
    @discardableResult
    func eaddCurve(to endPoint: CGPoint, control1: CGPoint, control2: CGPoint, transform: CGAffineTransform = .identity) -> Self {
        self.addCurve(to: endPoint, control1: control1, control2: control2, transform: transform)
        return self
    }
}

extension CGPath {
    
    /// Helper to perform a mutation on a mutable copy of the path and return it as an immutable CGPath
    private func mutating(_ body: (CGMutablePath) -> Void) -> CGPath {
        let mutableCopy = self.mutableCopy() ?? CGMutablePath()
        body(mutableCopy)
        return mutableCopy as CGPath
    }
    
    @discardableResult
    func emove(to point: CGPoint, transform: CGAffineTransform = .identity) -> CGPath {
        return mutating { $0.move(to: point, transform: transform) }
    }
    
    @discardableResult
    func eaddLine(to point: CGPoint, transform: CGAffineTransform = .identity) -> CGPath {
        return mutating { $0.addLine(to: point, transform: transform) }
    }

    @discardableResult
    func ecloseSubpath() -> CGPath {
        return mutating { $0.closeSubpath() }
    }
    
    @discardableResult
    func eaddRect(_ rect: CGRect, transform: CGAffineTransform = .identity) -> CGPath {
        return mutating { $0.addRect(rect, transform: transform) }
    }
    
    @discardableResult
    func eaddRects(_ rects: [CGRect], transform: CGAffineTransform = .identity) -> CGPath {
        return mutating { $0.addRects(rects, transform: transform) }
    }
    
    @discardableResult
    func eaddLines(between points: [CGPoint], transform: CGAffineTransform = .identity) -> CGPath {
        return mutating { $0.addLines(between: points, transform: transform) }
    }
    
    @discardableResult
    func eaddEllipse(in rect: CGRect, transform: CGAffineTransform = .identity) -> CGPath {
        return mutating { $0.addEllipse(in: rect, transform: transform) }
    }
    
    @discardableResult
    func eaddRelativeArc(center: CGPoint, radius: CGFloat, startAngle: CGFloat, delta: CGFloat, transform: CGAffineTransform = .identity) -> CGPath {
        return mutating { $0.addRelativeArc(center: center, radius: radius, startAngle: startAngle, delta: delta, transform: transform) }
    }
    
    @discardableResult
    func eaddArc(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool, transform: CGAffineTransform = .identity) -> CGPath {
        return mutating { $0.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise, transform: transform) }
    }
    
    @discardableResult
    func eaddArc(tangent1End: CGPoint, tangent2End: CGPoint, radius: CGFloat, transform: CGAffineTransform = .identity) -> CGPath {
        return mutating { $0.addArc(tangent1End: tangent1End, tangent2End: tangent2End, radius: radius, transform: transform) }
    }
    
    @discardableResult
    func eaddPath(_ path: CGPath, transform: CGAffineTransform = .identity) -> CGPath {
        return mutating { $0.addPath(path, transform: transform) }
    }
}
