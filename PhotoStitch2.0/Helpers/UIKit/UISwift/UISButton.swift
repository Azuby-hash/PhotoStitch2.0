//
//  UISButton.swift
//  StitchPhotos2.0
//
//  Created by TapUniverse Dev9 on 12/3/26.
//

import UIKit

extension UIButton {
    @discardableResult
    func esetTitle(_ title: String?, for state: UIControl.State = .normal) -> Self {
        setTitle(title, for: state)
        return self
    }
    
    @discardableResult
    func esetTitleColor(_ color: UIColor?, for state: UIControl.State = .normal) -> Self {
        setTitleColor(color, for: state)
        return self
    }
    
    @discardableResult
    func esetTitleShadowColor(_ color: UIColor?, for state: UIControl.State = .normal) -> Self {
        setTitleShadowColor(color, for: state)
        return self
    }
    
    @discardableResult
    func esetImage(_ image: UIImage?, for state: UIControl.State = .normal) -> Self {
        setImage(image, for: state)
        return self
    }
    
    @discardableResult
    func esetBackgroundImage(_ image: UIImage?, for state: UIControl.State = .normal) -> Self {
        setBackgroundImage(image, for: state)
        return self
    }
    
    @discardableResult
    func esetPreferredSymbolConfiguration(_ configuration: UIImage.SymbolConfiguration?, forImageIn state: UIControl.State) -> Self {
        setPreferredSymbolConfiguration(configuration, forImageIn: state)
        return self
    }
    
    @discardableResult
    func esetAttributedTitle(_ title: NSAttributedString?, for state: UIControl.State = .normal) -> Self {
        setAttributedTitle(title, for: state)
        return self
    }
    
    @discardableResult
    func efont(_ font: UIFont) -> Self {
        titleLabel?.font = font
        return self
    }
    
    @discardableResult
    func econfiguration(_ configuration: @escaping (UIButton.Configuration?) -> UIButton.Configuration?) -> Self {
        self.configuration = configuration(self.configuration)
        return self
    }
}
