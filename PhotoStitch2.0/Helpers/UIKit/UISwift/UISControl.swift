//
//  UISControl.swift
//  StitchPhotos2.0
//
//  Created by TapUniverse Dev9 on 12/3/26.
//

import UIKit

extension UIControl {
    @discardableResult
    func eisEnabled(_ isEnabled: Bool) -> Self {
        self.isEnabled = isEnabled
        return self
    }
    
    @discardableResult
    func eisSelected(_ isSelected: Bool) -> Self {
        self.isSelected = isSelected
        return self
    }
    
    @discardableResult
    func eisHighlighted(_ isHighlighted: Bool) -> Self {
        self.isHighlighted = isHighlighted
        return self
    }
    
    @discardableResult
    func econtentVerticalAlignment(_ alignment: UIControl.ContentVerticalAlignment) -> Self {
        self.contentVerticalAlignment = alignment
        return self
    }
    
    @discardableResult
    func econtentHorizontalAlignment(_ alignment: UIControl.ContentHorizontalAlignment) -> Self {
        self.contentHorizontalAlignment = alignment
        return self
    }
    
    @discardableResult
    func eaddTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) -> Self {
        addTarget(target, action: action, for: controlEvents)
        return self
    }
    
    @discardableResult
    func eremoveTarget(_ target: Any?, action: Selector?, for controlEvents: UIControl.Event) -> Self {
        removeTarget(target, action: action, for: controlEvents)
        return self
    }
}
