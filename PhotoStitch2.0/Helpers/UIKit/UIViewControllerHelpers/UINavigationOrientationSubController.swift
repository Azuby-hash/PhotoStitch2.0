//
//  UINavigationControllerOrientationSubVC.swift
//  PushUpCounter
//
//  Created by TapUniverse Dev9 on 24/11/25.
//

import UIKit

class UINavigationOrientationSubController: UINavigationController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return topViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
    }
}
