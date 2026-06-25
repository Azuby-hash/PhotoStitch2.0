//
//  Color.swift
//  Photo Stitch
//
//  Created by Azuby on 6/16/25.
//

import UIKit
import SwiftUI

extension UIColor {
    static let _primary = UIColor(named: "Primary")!
    static let _primary15 = UIColor(named: "Primary15")!
    static let _gray = UIColor(named: "Gray")!
    static let _medium = UIColor(named: "Medium")!
    static let _white = UIColor(named: "White")!
    static let _whiteVert = UIColor(named: "WhiteVert")!
    static let _black = UIColor(named: "Black")!
    static let _blackVert = UIColor(named: "BlackVert")!
    static let _light = UIColor(named: "Light")!
    static let _seperate = UIColor(named: "Seperate")!
    static let _background = UIColor(named: "Background")!
    static let _red = UIColor(named: "Red")!
    static let _red15 = UIColor(named: "Red15")!
    static let _yellow = UIColor(named: "Yellow")!
    static let _disable = UIColor(named: "Disable")!
    static let _secondary = UIColor(named: "Secondary")!
}

extension CGColor {
    static let _primary = UIColor._primary.cgColor
    static let _primary15 = UIColor._primary15.cgColor
    static let _gray = UIColor._gray.cgColor
    static let _medium = UIColor._medium.cgColor
    static let _white = UIColor._white.cgColor
    static let _whiteVert = UIColor._whiteVert.cgColor
    static let _black = UIColor._black.cgColor
    static let _blackVert = UIColor._blackVert.cgColor
    static let _light = UIColor._light.cgColor
    static let _seperate = UIColor._seperate.cgColor
    static let _background = UIColor._background.cgColor
    static let _red = UIColor._red.cgColor
    static let _red15 = UIColor._red15.cgColor
    static let _yellow = UIColor._yellow.cgColor
    static let _disable = UIColor._disable.cgColor
    static let _secondary = UIColor._secondary.cgColor
}

extension CIColor {
    static let _primary = CIColor(color: UIColor._primary)
    static let _primary15 = CIColor(color: UIColor._primary15)
    static let _gray = CIColor(color: UIColor._gray)
    static let _medium = CIColor(color: UIColor._medium)
    static let _white = CIColor(color: UIColor._white)
    static let _whiteVert = CIColor(color: UIColor._whiteVert)
    static let _black = CIColor(color: UIColor._black)
    static let _blackVert = CIColor(color: UIColor._blackVert)
    static let _light = CIColor(color: UIColor._light)
    static let _seperate = CIColor(color: UIColor._seperate)
    static let _background = CIColor(color: UIColor._background)
    static let _red = CIColor(color: UIColor._red)
    static let _red15 = CIColor(color: UIColor._red15)
    static let _yellow = CIColor(color: UIColor._yellow)
    static let _disable = CIColor(color: UIColor._disable)
    static let _secondary = CIColor(color: UIColor._secondary)
}

extension Color {
    init(hex: String) {
        let cleanedHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        let scanner = Scanner(string: cleanedHex)
        var hexValue: UInt64 = 0
        scanner.scanHexInt64(&hexValue)
        
        let r, g, b, a: Double
        
        switch cleanedHex.count {
        case 6: // RGB (24-bit)
            r = Double((hexValue & 0xFF0000) >> 16) / 255.0
            g = Double((hexValue & 0x00FF00) >> 8) / 255.0
            b = Double(hexValue & 0x0000FF) / 255.0
            a = 1.0
        case 8: // RGBA (32-bit)
            r = Double((hexValue & 0xFF000000) >> 24) / 255.0
            g = Double((hexValue & 0x00FF0000) >> 16) / 255.0
            b = Double((hexValue & 0x0000FF00) >> 8) / 255.0
            a = Double(hexValue & 0x000000FF) / 255.0
        default:
            // Default to black if format is invalid
            (r, g, b, a) = (0, 0, 0, 1)
        }
        
        self.init(red: r, green: g, blue: b, opacity: a)
    }
    
    static let _primary = Color("Primary")
    static let _primary15 = Color("Primary15")
    static let _gray = Color("Gray")
    static let _medium = Color("Medium")
    static let _white = Color("White")
    static let _whiteVert = Color("WhiteVert")
    static let _black = Color("Black")
    static let _blackVert = Color("BlackVert")
    static let _light = Color("Light")
    static let _seperate = Color("Seperate")
    static let _background = Color("Background")
    static let _red = Color("Red")
    static let _red15 = Color("Red15")
    static let _yellow = Color("Yellow")
    static let _disable = Color("Disable")
    static let _secondary = Color("Secondary")
}
