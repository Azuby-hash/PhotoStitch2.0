//
//  UIScrollViewPointOut.swift
//  VideoRemoveObject
//
//  Created by TapUniverse Dev9 on 25/4/25.
//

import UIKit

class UIScrollViewPointOut: UIScrollView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return true
    }
}
