//
//  MeshHelpers.swift
//  ModuleTest
//
//  Created by TapUniverse Dev9 on 22/8/25.
//

import UIKit
import CoreGraphics

struct Point: Hashable {
    public let x: Double
    public let y: Double
    
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    
    func toCGPoint() -> CGPoint {
        return .init(x: x, y: y)
    }
}

struct Circumcircle: Hashable {
    let point1: Point
    let point2: Point
    let point3: Point
    let x: Double
    let y: Double
    let rsqr: Double
}

struct Triangle {
    let point1: CGPoint
    let point2: CGPoint
    let point3: CGPoint
    
    init(point1: CGPoint, point2: CGPoint, point3: CGPoint) {
        self.point1 = point1
        self.point2 = point2
        self.point3 = point3
    }
}

class MeshHelpers {
    static func triangulate(_ points: [CGPoint]) -> [Triangle] {
        var points = Array(Set(points.map({ Point(x: $0.x, y: $0.y) })))
        
        guard points.count >= 3 else {
            return [Triangle]()
        }
        
        let n = points.count
        var open = [Circumcircle]()
        var completed = [Circumcircle]()
        var edges = [Point]()
        
        /* Make an array of indices into the point array, sorted by the
         * points' x-position. */
        let indices = [Int](0..<n).sorted {  points[$0].x < points[$1].x }
        
        /* Next, find the points of the supertriangle (which contains all other
         * triangles) */
        
        points += supertriangle(points)
        
        /* Initialize the open list (containing the supertriangle and nothing
         * else) and the closed list (which is empty since we havn't processed
         * any triangles yet). */
        open.append(circumcircle(points[n], j: points[n + 1], k: points[n + 2]))
        
        /* Incrementally add each point to the mesh. */
        for i in 0..<n {
            let c = indices[i]
            
            edges.removeAll()
            
            /* For each open triangle, check to see if the current point is
             * inside it's circumcircle. If it is, remove the triangle and add
             * it's edges to an edge list. */
            for j in (0..<open.count).reversed() {
                
                /* If this point is to the right of this triangle's circumcircle,
                 * then this triangle should never get checked again. Remove it
                 * from the open list, add it to the closed list, and skip. */
                let dx = points[c].x - open[j].x
                
                if dx > 0 && dx * dx > open[j].rsqr {
                    completed.append(open.remove(at: j))
                    continue
                }
                
                /* If we're outside the circumcircle, skip this triangle. */
                let dy = points[c].y - open[j].y
                
                if dx * dx + dy * dy - open[j].rsqr > Double.ulpOfOne {
                    continue
                }
                
                /* Remove the triangle and add it's edges to the edge list. */
                edges += [
                    open[j].point1, open[j].point2,
                    open[j].point2, open[j].point3,
                    open[j].point3, open[j].point1
                ]
                
                open.remove(at: j)
            }
            
            /* Remove any doubled edges. */
            edges = dedup(edges)
            
            /* Add a new triangle for each edge. */
            var j = edges.count
            while j > 0 {
                
                j -= 1
                let b = edges[j]
                j -= 1
                let a = edges[j]
                open.append(circumcircle(a, j: b, k: points[c]))
            }
        }
        
        /* Copy any remaining open triangles to the closed list, and then
         * remove any triangles that share a point with the supertriangle,
         * building a list of triplets that represent triangles. */
        completed += open
        
        let ignored: Set<Point> = [points[n], points[n + 1], points[n + 2]]
        
        let results = completed.compactMap { (circumCircle) -> Triangle? in
            
            let current: Set<Point> = [circumCircle.point1, circumCircle.point2, circumCircle.point3]
            let intersection = ignored.intersection(current)
            if intersection.count > 0 {
                return nil
            }
            
            return Triangle(point1: circumCircle.point1.toCGPoint(), point2: circumCircle.point2.toCGPoint(), point3: circumCircle.point3.toCGPoint())
        }
        
        /* Yay, we're done! */
        return results
    }
    
    static func cropToTriangle(image: CIImage, triangle: [CGPoint]) -> ([CGPoint], CIImage)? {
        guard triangle.count == 3 else { return nil }
        
        let minX = triangle.map { $0.x }.min() ?? 0
        let minY = triangle.map { $0.y }.min() ?? 0
        let maxX = triangle.map { $0.x }.max() ?? 0
        let maxY = triangle.map { $0.y }.max() ?? 0
        
        let boundingRect = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
        
        let croppedImage = image.cropped(to: CGRect(x: boundingRect.minX, y: image.extent.height - boundingRect.maxY,
                                                    width: boundingRect.width, height: boundingRect.height))
        let triangleCropped = triangle.map { CGPoint(x: $0.x - minX, y: $0.y - minY) }
        
        return (triangleCropped, croppedImage)
    }
}

extension MeshHelpers {
    /// Generates a supertraingle containing all other triangles
    static private func supertriangle(_ points: [Point]) -> [Point] {
        var xmin = Double(Int32.max)
        var ymin = Double(Int32.max)
        var xmax = -Double(Int32.max)
        var ymax = -Double(Int32.max)
        
        for i in 0..<points.count {
            if points[i].x < xmin { xmin = points[i].x }
            if points[i].x > xmax { xmax = points[i].x }
            if points[i].y < ymin { ymin = points[i].y }
            if points[i].y > ymax { ymax = points[i].y }
        }
        
        let dx = xmax - xmin
        let dy = ymax - ymin
        let dmax = max(dx, dy)
        let xmid = xmin + dx * 0.5
        let ymid = ymin + dy * 0.5
        
        return [
            Point(x: xmid - 20 * dmax, y: ymid - dmax),
            Point(x: xmid, y: ymid + 20 * dmax),
            Point(x: xmid + 20 * dmax, y: ymid - dmax)
        ]
    }
    
    /// Calculate the intersecting circumcircle for a set of 3 points
    static private func circumcircle(_ i: Point, j: Point, k: Point) -> Circumcircle {
        let x1 = i.x
        let y1 = i.y
        let x2 = j.x
        let y2 = j.y
        let x3 = k.x
        let y3 = k.y
        let xc: Double
        let yc: Double
        
        let fabsy1y2 = abs(y1 - y2)
        let fabsy2y3 = abs(y2 - y3)
        
        if fabsy1y2 < Double.ulpOfOne {
            let m2 = -((x3 - x2) / (y3 - y2))
            let mx2 = (x2 + x3) / 2
            let my2 = (y2 + y3) / 2
            xc = (x2 + x1) / 2
            yc = m2 * (xc - mx2) + my2
        } else if fabsy2y3 < Double.ulpOfOne {
            let m1 = -((x2 - x1) / (y2 - y1))
            let mx1 = (x1 + x2) / 2
            let my1 = (y1 + y2) / 2
            xc = (x3 + x2) / 2
            yc = m1 * (xc - mx1) + my1
        } else {
            let m1 = -((x2 - x1) / (y2 - y1))
            let m2 = -((x3 - x2) / (y3 - y2))
            let mx1 = (x1 + x2) / 2
            let mx2 = (x2 + x3) / 2
            let my1 = (y1 + y2) / 2
            let my2 = (y2 + y3) / 2
            xc = (m1 * mx1 - m2 * mx2 + my2 - my1) / (m1 - m2)
            
            if fabsy1y2 > fabsy2y3 {
                yc = m1 * (xc - mx1) + my1
            } else {
                yc = m2 * (xc - mx2) + my2
            }
        }
        
        let dx = x2 - xc
        let dy = y2 - yc
        let rsqr = dx * dx + dy * dy
        
        return Circumcircle(point1: i, point2: j, point3: k, x: xc, y: yc, rsqr: rsqr)
    }
    
    /// Deduplicate a collection of edges
    static private func dedup(_ edges: [Point]) -> [Point] {
        var e = edges
        var a: Point?, b: Point?, m: Point?, n: Point?
        
        var j = e.count
        while j > 0 {
            j -= 1
            b = j < e.count ? e[j] : nil
            j -= 1
            a = j < e.count ? e[j] : nil
            
            var i = j
            while i > 0 {
                i -= 1
                n = e[i]
                i -= 1
                m = e[i]
                
                if (a == m && b == n) || (a == n && b == m) {
                    e.removeSubrange(j...j + 1)
                    e.removeSubrange(i...i + 1)
                    break
                }
            }
        }
        
        return e
    }
}
