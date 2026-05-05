//
//  CGPathHelpers.swift
//  PrinttoSize
//
//  Created by TapUniverse Dev9 on 10/1/25.
//

import UIKit
import Vision

extension CGPath {
    func simplifyPath(tolerance: CGFloat) -> CGPath {
        var points: [(CGPoint, CGPathElementType)] = [] // Store points with their type

        // Extract points and their types from the original path
        applyWithBlock { element in
            let pointsInElement = element.pointee.points
            let type = element.pointee.type

            switch type {
            case .moveToPoint:
                points.append((pointsInElement[0], type))
            case .addLineToPoint:
                points.append((pointsInElement[0], type))
            case .addQuadCurveToPoint:
                points.append((pointsInElement[0], .addQuadCurveToPoint)) // Control point
                points.append((pointsInElement[1], type))                 // End point
            case .addCurveToPoint:
                points.append((pointsInElement[0], .addCurveToPoint))     // Control point 1
                points.append((pointsInElement[1], .addCurveToPoint))     // Control point 2
                points.append((pointsInElement[2], type))                 // End point
            case .closeSubpath:
                points.append((.zero, type)) // Close subpath is treated separately
            @unknown default:
                break
            }
        }

        // Filter line segments using Douglas-Peucker while keeping curve points
        var simplifiedPoints: [(CGPoint, CGPathElementType)] = []
        var currentLineSegment: [CGPoint] = []

        for point in points {
            switch point.1 {
            case .moveToPoint:
                if !currentLineSegment.isEmpty {
                    simplifiedPoints += simplifyLineSegment(currentLineSegment, tolerance: tolerance)
                    currentLineSegment.removeAll()
                }
                simplifiedPoints.append(point) // Move-to is always added
            case .addLineToPoint:
                currentLineSegment.append(point.0)
            case .addQuadCurveToPoint, .addCurveToPoint:
                if !currentLineSegment.isEmpty {
                    simplifiedPoints += simplifyLineSegment(currentLineSegment, tolerance: tolerance)
                    currentLineSegment.removeAll()
                }
                simplifiedPoints.append(point) // Add curve or quad points directly
            case .closeSubpath:
                if !currentLineSegment.isEmpty {
                    simplifiedPoints += simplifyLineSegment(currentLineSegment, tolerance: tolerance)
                    currentLineSegment.removeAll()
                }
                simplifiedPoints.append(point)
            default:
                break
            }
        }

        if !currentLineSegment.isEmpty {
            simplifiedPoints += simplifyLineSegment(currentLineSegment, tolerance: tolerance)
        }

        // Rebuild the simplified path
        let simplifiedPath = CGMutablePath()
        for i in 0..<simplifiedPoints.count {
            let point = simplifiedPoints[i]
            switch point.1 {
            case .moveToPoint:
                simplifiedPath.move(to: point.0)
            case .addLineToPoint:
                simplifiedPath.addLine(to: point.0)
            case .addQuadCurveToPoint:
                let controlPoint = simplifiedPoints[i - 1].0
                simplifiedPath.addQuadCurve(to: point.0, control: controlPoint)
            case .addCurveToPoint:
                let controlPoint1 = simplifiedPoints[i - 2].0
                let controlPoint2 = simplifiedPoints[i - 1].0
                simplifiedPath.addCurve(to: point.0, control1: controlPoint1, control2: controlPoint2)
            case .closeSubpath:
                simplifiedPath.closeSubpath()
            default:
                break
            }
        }

        return simplifiedPath
    }

    private func simplifyLineSegment(_ points: [CGPoint], tolerance: CGFloat) -> [(CGPoint, CGPathElementType)] {
        guard points.count > 2 else {
            return points.map { ($0, .addLineToPoint) }
        }

        let simplified = douglasPeucker(points, tolerance: tolerance)
        return simplified.map { ($0, .addLineToPoint) }
    }

    private func douglasPeucker(_ points: [CGPoint], tolerance: CGFloat) -> [CGPoint] {
        guard points.count > 2,
              let start = points.first,
              let end = points.last
        else { return points }

        var maxDistance: CGFloat = 0
        var farthestIndex: Int = 0

        for i in 1..<points.count - 1 {
            let distance = perpendicularDistance(from: points[i], toLineStart: start, toLineEnd: end)
            if distance > maxDistance {
                maxDistance = distance
                farthestIndex = i
            }
        }

        if maxDistance > tolerance {
            let left = douglasPeucker(Array(points[0...farthestIndex]), tolerance: tolerance)
            let right = douglasPeucker(Array(points[farthestIndex...]), tolerance: tolerance)
            return left + right.dropFirst()
        } else {
            return [start, end]
        }
    }

    private func perpendicularDistance(from point: CGPoint, toLineStart start: CGPoint, toLineEnd end: CGPoint) -> CGFloat {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let area = abs(dx * (start.y - point.y) - (start.x - point.x) * dy)
        let length = sqrt(dx * dx + dy * dy)
        return area / length
    }
}

extension VNContoursObservation {
    func simplifyPath(tolerance: CGFloat) -> CGPath {
        let path = UIBezierPath()
        
        topLevelContours.forEach { contour in
            do {
                let simpContour = try contour.polygonApproximation(epsilon: Float(tolerance))
                path.append(UIBezierPath(cgPath: simpContour.normalizedPath))
            } catch {
                path.append(UIBezierPath(cgPath: contour.normalizedPath))
            }
        }
        
        return path.cgPath
    }
}
