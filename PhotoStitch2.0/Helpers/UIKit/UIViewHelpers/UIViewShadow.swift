//
//  UIViewInspectable.swift
//  BlurVideo2.0
//
//  Created by TapUniverse Dev9 on 23/9/24.
//

import UIKit

class UIViewShadow: UIView {
    @IBInspectable var shadowOffset: CGSize {
        get { return layer.shadowOffset }
        set { layer.shadowOffset = newValue }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        get { return layer.shadowRadius }
        set { layer.shadowRadius = newValue }
    }
    
    @IBInspectable var shadowColor: UIColor {
        get { return UIColor(cgColor: layer.shadowColor ?? .init(gray: 0, alpha: 1)) }
        set { layer.shadowColor = newValue.cgColor }
    }
    
    @IBInspectable var shadowOpacity: Float {
        get { return layer.shadowOpacity }
        set { layer.shadowOpacity = newValue }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self], target: self, action: #selector(traitCollectionDidChange))
        }
    }

    @objc override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        layer.shadowColor = shadowColor.cgColor
    }
}
