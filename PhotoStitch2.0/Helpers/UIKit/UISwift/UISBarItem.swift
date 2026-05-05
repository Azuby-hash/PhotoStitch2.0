//
//  UISBarItem.swift
//  StitchPhotos2.0
//
//  Created by TapUniverse Dev9 on 16/3/26.
//

import UIKit

extension UIBarButtonItem {
    func estyle(style: UIBarButtonItem.Style) -> Self {
        self.style = style
        return self
    }
    
    func ewidth(width: CGFloat) -> Self {
        self.width = width
        return self
    }
    
    func epossibleTitles(possibleTitles: Set<String>?) -> Self {
        self.possibleTitles = possibleTitles
        return self
    }
    
    func ecustomView(customView: UIView?) -> Self {
        self.customView = customView
        return self
    }
    
    func eaction(action: Selector?) -> Self {
        self.action = action
        return self
    }
    
    func etarget(target: AnyObject?) -> Self {
        self.target = target
        return self
    }
    
    func eprimaryAction(primaryAction: UIAction?) -> Self {
        self.primaryAction = primaryAction
        return self
    }
    
    func emenu(menu: UIMenu?) -> Self {
        self.menu = menu
        return self
    }
    
    @available(iOS 16.0, *)
    func epreferredMenuElementOrder(preferredMenuElementOrder: UIContextMenuConfiguration.ElementOrder) -> Self {
        self.preferredMenuElementOrder = preferredMenuElementOrder
        return self
    }
    
    func echangesSelectionAsPrimaryAction(changesSelectionAsPrimaryAction: Bool) -> Self {
        self.changesSelectionAsPrimaryAction = changesSelectionAsPrimaryAction
        return self
    }
    
    func eisSelected(isSelected: Bool) -> Self {
        self.isSelected = isSelected
        return self
    }
    
    @available(iOS 16.0, *)
    func eisHidden(isHidden: Bool) -> Self {
        self.isHidden = isHidden
        return self
    }
    
    @available(iOS 17.0, *)
    func eisSymbolAnimationEnabled(isSymbolAnimationEnabled: Bool) -> Self {
        self.isSymbolAnimationEnabled = isSymbolAnimationEnabled
        return self
    }
    
    @available(iOS 16.0, *)
    func emenuRepresentation(menuRepresentation: UIMenuElement?) -> Self {
        self.menuRepresentation = menuRepresentation
        return self
    }
    
    @available(iOS 26.0, *)
    func ehidesSharedBackground(hidesSharedBackground: Bool) -> Self {
        self.hidesSharedBackground = hidesSharedBackground
        return self
    }
    
    @available(iOS 26.0, *)
    func esharesBackground(sharesBackground: Bool) -> Self {
        self.sharesBackground = sharesBackground
        return self
    }
    
    @available(iOS 26.0, *)
    func eidentifier(identifier: String?) -> Self {
        self.identifier = identifier
        return self
    }
    
    func esetBackgroundImage(_ backgroundImage: UIImage?, for state: UIControl.State, barMetrics: UIBarMetrics) -> Self {
        self.setBackgroundImage(backgroundImage, for: state, barMetrics: barMetrics)
        return self
    }

    func esetBackgroundImage(_ backgroundImage: UIImage?, for state: UIControl.State, style: UIBarButtonItem.Style, barMetrics: UIBarMetrics) -> Self {
        self.setBackgroundImage(backgroundImage, for: state, style: style, barMetrics: barMetrics)
        return self
    }

    func esetBackgroundVerticalPositionAdjustment(_ adjustment: CGFloat, for barMetrics: UIBarMetrics) -> Self {
        self.setBackgroundVerticalPositionAdjustment(adjustment, for: barMetrics)
        return self
    }
    
    func esetTitlePositionAdjustment(_ adjustment: UIOffset, for barMetrics: UIBarMetrics) -> Self {
        self.setTitlePositionAdjustment(adjustment, for: barMetrics)
        return self
    }
    
    func esetBackButtonBackgroundImage(_ backgroundImage: UIImage?, for state: UIControl.State, barMetrics: UIBarMetrics) -> Self {
        self.setBackButtonBackgroundImage(backgroundImage, for: state, barMetrics: barMetrics)
        return self
    }
    
    func esetBackButtonTitlePositionAdjustment(_ adjustment: UIOffset, for barMetrics: UIBarMetrics) -> Self {
        self.setBackButtonTitlePositionAdjustment(adjustment, for: barMetrics)
        return self
    }
    
    func esetBackButtonBackgroundVerticalPositionAdjustment(_ adjustment: CGFloat, for barMetrics: UIBarMetrics) -> Self {
        self.setBackButtonBackgroundVerticalPositionAdjustment(adjustment, for: barMetrics)
        return self
    }
}

