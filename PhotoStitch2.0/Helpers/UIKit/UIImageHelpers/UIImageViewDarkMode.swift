//
//  UIImageViewDarkMode.swift
//  AIPhotoEditor
//
//  Created by TapUniverse Dev9 on 30/8/24.
//

import UIKit

class UIImageViewDarkMode: UIImageView {

    @IBInspectable var name: String = "" {
        didSet {
            setImage()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self], target: self, action: #selector(traitCollectionDidChange))
        }
    }

    @objc override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // Check if the user interface style has changed
        setImage()
    }

    private func setImage() {
        image = UIImage(named: "\(name)\(traitCollection.userInterfaceStyle == .light ? "Light" : "Dark")")
    }
}
