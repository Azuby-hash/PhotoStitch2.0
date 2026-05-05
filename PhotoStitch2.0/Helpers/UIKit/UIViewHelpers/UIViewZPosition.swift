//
//  UIViewZPosition.swift
//  PrinttoSize
//
//  Created by TapUniverse Dev9 on 18/12/24.
//

import UIKit

class UIViewZPosition: UIView {
    @IBInspectable var zPosition: CGFloat = 0 {
        didSet {
            layer.zPosition = zPosition
        }
    }
}
