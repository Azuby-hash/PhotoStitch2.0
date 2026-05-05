//
//  UIMask.swift
//  ModuleTest
//
//  Created by TapUniverse Dev9 on 11/10/2023.
//

import UIKit

/**
 A view that use one of its subview to mask itself
 Subview have **restorationIdentifier** same as **maskId** keyPath
 */
class UIViewMask: UIView {
    @IBInspectable var maskId: String = ""
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var _mask: UIView?
        
        for view in subviews {
            if view.restorationIdentifier == maskId {
                _mask = view
                break
            }
        }
        
        guard let _mask = _mask else { return }
        
        mask = _mask
        _mask.frame = bounds
    }

}
