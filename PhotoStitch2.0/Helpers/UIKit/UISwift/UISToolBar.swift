//
//  UISToolBar.swift
//  StitchPhotos2.0
//
//  Created by TapUniverse Dev9 on 13/3/26.
//

import UIKit

extension UIToolbar {
    @discardableResult
    func ebarStyle(_ barStyle: UIBarStyle) -> Self {
        self.barStyle = barStyle
        return self
    }
    
    @discardableResult
    func eitems(_ items: [UIBarButtonItem]?) -> Self {
        self.items = items
        return self
    }
    
    @discardableResult
    func eisTranslucent(_ isTranslucent: Bool) -> Self {
        self.isTranslucent = isTranslucent
        return self
    }
    
    @discardableResult
    func esetItems(_ items: [UIBarButtonItem]?, animated: Bool) -> Self {
        self.setItems(items, animated: animated)
        return self
    }
    
    @discardableResult
    func ebarTintColor(_ barTintColor: UIColor?) -> Self {
        self.barTintColor = barTintColor
        return self
    }
    
    @discardableResult
    func esetBackgroundImage(_ backgroundImage: UIImage?, forToolbarPosition topOrBottom: UIBarPosition, barMetrics: UIBarMetrics) -> Self {
        self.setBackgroundImage(backgroundImage, forToolbarPosition: topOrBottom, barMetrics: barMetrics)
        return self
    }
    
    @discardableResult
    func esetShadowImage(_ shadowImage: UIImage?, forToolbarPosition topOrBottom: UIBarPosition) -> Self {
        self.setShadowImage(shadowImage, forToolbarPosition: topOrBottom)
        return self
    }
    
    @discardableResult
    func estandardAppearance(_ standardAppearance: UIToolbarAppearance) -> Self {
        self.standardAppearance = standardAppearance
        return self
    }
    
    @discardableResult
    func ecompactAppearance(_ compactAppearance: UIToolbarAppearance?) -> Self {
        self.compactAppearance = compactAppearance
        return self
    }
    
    @discardableResult
    func escrollEdgeAppearance(_ scrollEdgeAppearance: UIToolbarAppearance?) -> Self {
        self.scrollEdgeAppearance = scrollEdgeAppearance
        return self
    }
    
    @discardableResult
    func ecompactScrollEdgeAppearance(_ compactScrollEdgeAppearance: UIToolbarAppearance?) -> Self {
        self.compactScrollEdgeAppearance = compactScrollEdgeAppearance
        return self
    }
    
    @discardableResult
    func edelegate(_ delegate: (any UIToolbarDelegate)?) -> Self {
        self.delegate = delegate
        return self
    }
}
