//
//  UIStackViewShadow.swift
//  AnimeFilters2
//
//  Created by Tap Dev5 on 24/02/2023.
//

import UIKit

class UIStackViewPointSubview: UIStackView {

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var isTouch = false
        for subview in arrangedSubviews {
            if subview.point(inside: convert(point, to: subview), with: event) && subview.alpha > 0.01 {
                isTouch = true
                break
            }
        }
        return isTouch
    }

}
