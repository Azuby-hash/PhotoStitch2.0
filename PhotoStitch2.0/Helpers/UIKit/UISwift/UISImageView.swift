//
//  UISImageView.swift
//  StitchPhotos2.0
//
//  Created by TapUniverse Dev9 on 12/3/26.
//

import UIKit

extension UIImageView {
    @discardableResult
    func eimage(_ image: UIImage?) -> Self {
        self.image = image
        return self
    }
    
    @discardableResult
    func ehighlightedImage(_ highlightedImage: UIImage?) -> Self {
        self.highlightedImage = highlightedImage
        return self
    }
    
    @discardableResult
    func epreferredSymbolConfiguration(_ preferredSymbolConfiguration: UIImage.SymbolConfiguration?) -> Self {
        self.preferredSymbolConfiguration = preferredSymbolConfiguration
        return self
    }

    @discardableResult
    func eisHighlighted(_ isHighlighted: Bool) -> Self {
        self.isHighlighted = isHighlighted
        return self
    }
    
    @discardableResult
    func eanimationImages(_ animationImages: [UIImage]?) -> Self {
        self.animationImages = animationImages
        return self
    }
    
    @discardableResult
    func ehighlightedAnimationImages(_ highlightedAnimationImages: [UIImage]?) -> Self {
        self.highlightedAnimationImages = highlightedAnimationImages
        return self
    }
    
    @discardableResult
    func eanimationDuration(_ animationDuration: TimeInterval) -> Self {
        self.animationDuration = animationDuration
        return self
    }
    
    @discardableResult
    func eanimationRepeatCount(_ animationRepeatCount: Int) -> Self {
        self.animationRepeatCount = animationRepeatCount
        return self
    }
    
    @discardableResult
    func epreferredImageDynamicRange(_ preferredImageDynamicRange: UIImage.DynamicRange) -> Self {
        self.preferredImageDynamicRange = preferredImageDynamicRange
        return self
    }
    
    @discardableResult
    func estartAnimating() -> Self {
        self.startAnimating()
        return self
    }
    
    @discardableResult
    func estopAnimating() -> Self {
        self.stopAnimating()
        return self
    }
}
