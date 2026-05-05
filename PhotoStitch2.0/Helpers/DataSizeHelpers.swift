//
//  DataSizeHelpers.swift
//  VideoRemoveObject
//
//  Created by TapUniverse Dev9 on 14/5/25.
//

import UIKit

fileprivate let formatter = ByteCountFormatter()

extension Float {
    func toSizeString(decimal: Int) -> String {
        let divisor: Float = 1024
        let units = ["B", "KB", "MB", "GB", "TB"]
        let decimal = Float(pow(10.0, 2.0))
        
        var bytes = self / 8.0
        
        // Find appropriate unit
        var unitIndex = 0
        while bytes >= divisor && unitIndex < units.count - 1 {
            bytes /= divisor
            unitIndex += 1
        }
        
        // Round to 2 decimal places
        let rounded = UIKit.round(bytes * decimal) / decimal
        
        // Format based on whether we need decimal places
        if rounded == Float(Int(rounded)) {
            return "\(Int(rounded)) \(units[unitIndex])"
        } else {
            return "\(rounded) \(units[unitIndex])"
        }
    }
    
    func toSizeString() -> String {
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(self))
    }
    
    func toDecimalString() -> String {
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .decimal
        return formatter.string(fromByteCount: Int64(self))
    }
}

extension Double {
    func toSizeString(decimal: Int) -> String {
        let divisor: Double = 1024
        let units = ["B", "KB", "MB", "GB", "TB"]
        let decimal = pow(10.0, 2.0)
        
        var bytes = self / 8.0
        
        // Find appropriate unit
        var unitIndex = 0
        while bytes >= divisor && unitIndex < units.count - 1 {
            bytes /= divisor
            unitIndex += 1
        }
        
        // Round to 2 decimal places
        let rounded = UIKit.round(bytes * decimal) / decimal
        
        // Format based on whether we need decimal places
        if rounded == Double(Int(rounded)) {
            return "\(Int(rounded)) \(units[unitIndex])"
        } else {
            return "\(rounded) \(units[unitIndex])"
        }
    }
    
    func toSizeString() -> String {
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(self))
    }
    
    func toDecimalString() -> String {
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .decimal
        return formatter.string(fromByteCount: Int64(self))
    }
}

extension CGFloat {
    func toSizeString(decimal: Int) -> String {
        let divisor: CGFloat = 1024
        let units = ["B", "KB", "MB", "GB", "TB"]
        let decimal = CGFloat(pow(10.0, 2.0))
        
        var bytes = self / 8.0
        
        // Find appropriate unit
        var unitIndex = 0
        while bytes >= divisor && unitIndex < units.count - 1 {
            bytes /= divisor
            unitIndex += 1
        }
        
        // Round to 2 decimal places
        let rounded = UIKit.round(bytes * decimal) / decimal
        
        // Format based on whether we need decimal places
        if rounded == CGFloat(Int(rounded)) {
            return "\(Int(rounded)) \(units[unitIndex])"
        } else {
            return "\(rounded) \(units[unitIndex])"
        }
    }
    
    func toSizeString() -> String {
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(self))
    }
    
    func toDecimalString() -> String {
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .decimal
        return formatter.string(fromByteCount: Int64(self))
    }
}
