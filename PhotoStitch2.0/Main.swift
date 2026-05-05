//
//  ViewController.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 4/25/26.
//

import UIKit
import SwiftUI

fileprivate(set) var VIEW_CONTROLLER = UIViewController()

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        VIEW_CONTROLLER = self
    }
}

class ViewHosting: UIHostingController<Home> {
    required init?(coder aDecoder: NSCoder) {
        super.init(rootView: Home())
    }
}
