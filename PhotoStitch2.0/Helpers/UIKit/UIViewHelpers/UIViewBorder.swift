//
//  UIViewBorder.swift
//  PrinttoSize
//
//  Created by TapUniverse Dev9 on 20/12/24.
//

import UIKit

class UIViewBorder: UIView {
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet { layer.borderWidth = borderWidth }
    }
    
    @IBInspectable var borderColor: UIColor = .clear {
        didSet { layer.borderColor = borderColor.cgColor }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self], target: self, action: #selector(traitCollectionDidChange))
        }
    }

    @objc override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        layer.borderColor = borderColor.cgColor
    }
}
