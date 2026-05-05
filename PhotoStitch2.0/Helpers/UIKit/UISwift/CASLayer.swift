//
//  CASLayer.swift
//  StitchPhotos2.0
//
//  Created by TapUniverse Dev9 on 12/3/26.
//

import UIKit

extension CALayer {
    @discardableResult
    func ezPosition(_ zPosition: CGFloat) -> Self {
        self.zPosition = zPosition
        
        return self
    }
    
    @discardableResult
    func eanchorPoint(_ anchorPoint: CGPoint) -> Self {
        self.anchorPoint = anchorPoint
        
        return self
    }
    
    @discardableResult
    func esetAffineTransform(_ m: CGAffineTransform) -> Self {
        setAffineTransform(m)
        
        return self
    }

    @discardableResult
    func eframe(_ frame: CGRect) -> Self {
        self.frame = frame
        
        return self
    }

    @discardableResult
    func eisHidden(_ isHidden: Bool) -> Self {
        self.isHidden = isHidden
        
        return self
    }

    @discardableResult
    func eaddSublayer(_ layer: CALayer) -> Self {
        addSublayer(layer)
        
        return self
    }

    @discardableResult
    func einsertSublayer(_ layer: CALayer, at idx: UInt32) -> Self {
        insertSublayer(layer, at: idx)
        
        return self
    }

    @discardableResult
    func einsertSublayer(_ layer: CALayer, below sibling: CALayer?) -> Self {
        insertSublayer(layer, below: sibling)
        
        return self
    }

    @discardableResult
    func einsertSublayer(_ layer: CALayer, above sibling: CALayer?) -> Self {
        insertSublayer(layer, above: sibling)
        
        return self
    }

    @discardableResult
    func ereplaceSublayer(_ oldLayer: CALayer, with newLayer: CALayer) -> Self {
        replaceSublayer(oldLayer, with: newLayer)
        
        return self
    }

    @discardableResult
    func emask(_ mask: CALayer?) -> Self {
        self.mask = mask
        
        return self
    }

    @discardableResult
    func emasksToBounds(_ masksToBounds: Bool) -> Self {
        self.masksToBounds = masksToBounds
        
        return self
    }

    @discardableResult
    func econtents(_ contents: Any?) -> Self {
        self.contents = contents
        
        return self
    }

    @discardableResult
    func econtentsRect(_ contentsRect: CGRect) -> Self {
        self.contentsRect = contentsRect
        
        return self
    }

    @discardableResult
    func econtentsGravity(_ contentsGravity: CALayerContentsGravity) -> Self {
        self.contentsGravity = contentsGravity
        
        return self
    }

    @discardableResult
    func econtentsScale(_ contentsScale: CGFloat) -> Self {
        self.contentsScale = contentsScale
        
        return self
    }

    @discardableResult
    func econtentsCenter(_ contentsCenter: CGRect) -> Self {
        self.contentsCenter = contentsCenter
        
        return self
    }

    @discardableResult
    func econtentsFormat(_ contentsFormat: CALayerContentsFormat) -> Self {
        self.contentsFormat = contentsFormat
        
        return self
    }

    @discardableResult
    func eminificationFilter(_ minificationFilter: CALayerContentsFilter) -> Self {
        self.minificationFilter = minificationFilter
        
        return self
    }

    @discardableResult
    func emagnificationFilter(_ magnificationFilter: CALayerContentsFilter) -> Self {
        self.magnificationFilter = magnificationFilter
        
        return self
    }

    @discardableResult
    func eminificationFilterBias(_ minificationFilterBias: Float) -> Self {
        self.minificationFilterBias = minificationFilterBias
        
        return self
    }

    @discardableResult
    func eisOpaque(_ isOpaque: Bool) -> Self {
        self.isOpaque = isOpaque
        
        return self
    }

    @discardableResult
    func edisplay() -> Self {
        display()
        
        return self
    }

    @discardableResult
    func esetNeedsDisplay() -> Self {
        setNeedsDisplay()
        
        return self
    }

    @discardableResult
    func esetNeedsDisplay(_ r: CGRect) -> Self {
        setNeedsDisplay(r)
        
        return self
    }

    @discardableResult
    func edisplayIfNeeded() -> Self {
        displayIfNeeded()
        
        return self
    }

    @discardableResult
    func eneedsDisplayOnBoundsChange(_ needsDisplayOnBoundsChange: Bool) -> Self {
        self.needsDisplayOnBoundsChange = needsDisplayOnBoundsChange
        
        return self
    }

    @discardableResult
    func edrawsAsynchronously(_ drawsAsynchronously: Bool) -> Self {
        self.drawsAsynchronously = drawsAsynchronously
        
        return self
    }

    @discardableResult
    func eedgeAntialiasingMask(_ edgeAntialiasingMask: CAEdgeAntialiasingMask) -> Self {
        self.edgeAntialiasingMask = edgeAntialiasingMask
        
        return self
    }

    @discardableResult
    func eallowsEdgeAntialiasing(_ allowsEdgeAntialiasing: Bool) -> Self {
        self.allowsEdgeAntialiasing = allowsEdgeAntialiasing
        
        return self
    }

    @discardableResult
    func ebackgroundColor(_ backgroundColor: CGColor?) -> Self {
        self.backgroundColor = backgroundColor
        
        return self
    }

    @discardableResult
    func ecornerRadius(_ cornerRadius: CGFloat) -> Self {
        self.cornerRadius = cornerRadius
        
        return self
    }

    @discardableResult
    func emaskedCorners(_ maskedCorners: CACornerMask) -> Self {
        self.maskedCorners = maskedCorners
        
        return self
    }

    @discardableResult
    func ecornerCurve(_ cornerCurve: CALayerCornerCurve) -> Self {
        self.cornerCurve = cornerCurve
        
        return self
    }

    @discardableResult
    func eborderWidth(_ borderWidth: CGFloat) -> Self {
        self.borderWidth = borderWidth
        
        return self
    }

    @discardableResult
    func eborderColor(_ borderColor: CGColor?) -> Self {
        self.borderColor = borderColor
        
        return self
    }

    @discardableResult
    func eopacity(_ opacity: Float) -> Self {
        self.opacity = opacity
        
        return self
    }

    @discardableResult
    func eallowsGroupOpacity(_ allowsGroupOpacity: Bool) -> Self {
        self.allowsGroupOpacity = allowsGroupOpacity
        
        return self
    }

    @discardableResult
    func ecompositingFilter(_ compositingFilter: Any?) -> Self {
        self.compositingFilter = compositingFilter
        
        return self
    }

    @discardableResult
    func efilters(_ filters: [Any]?) -> Self {
        self.filters = filters
        
        return self
    }

    @discardableResult
    func ebackgroundFilters(_ backgroundFilters: [Any]?) -> Self {
        self.backgroundFilters = backgroundFilters
        
        return self
    }

    @discardableResult
    func eshouldRasterize(_ shouldRasterize: Bool) -> Self {
        self.shouldRasterize = shouldRasterize
        
        return self
    }

    @discardableResult
    func erasterizationScale(_ rasterizationScale: CGFloat) -> Self {
        self.rasterizationScale = rasterizationScale
        
        return self
    }

    @discardableResult
    func eshadowColor(_ shadowColor: CGColor?) -> Self {
        self.shadowColor = shadowColor
        
        return self
    }

    @discardableResult
    func eshadowOpacity(_ shadowOpacity: Float) -> Self {
        self.shadowOpacity = shadowOpacity
        
        return self
    }

    @discardableResult
    func eshadowOffset(_ shadowOffset: CGSize) -> Self {
        self.shadowOffset = shadowOffset
        
        return self
    }

    @discardableResult
    func eshadowRadius(_ shadowRadius: CGFloat) -> Self {
        self.shadowRadius = shadowRadius
        
        return self
    }

    @discardableResult
    func eshadowPath(_ shadowPath: CGPath?) -> Self {
        self.shadowPath = shadowPath
        
        return self
    }

    @discardableResult
    func esetNeedsLayout() -> Self {
        setNeedsLayout()
        
        return self
    }

    @discardableResult
    func elayoutIfNeeded() -> Self {
        layoutIfNeeded()
        
        return self
    }

    @discardableResult
    func elayoutSublayers() -> Self {
        layoutSublayers()
        
        return self
    }
    
    @discardableResult
    func eadd(_ anim: CAAnimation, forKey key: String?) -> Self {
        add(anim, forKey: key)
        
        return self
    }

    @discardableResult
    func eremoveAllAnimations() -> Self {
        removeAllAnimations()
        
        return self
    }

    @discardableResult
    func eremoveAnimation(forKey key: String) -> Self {
        removeAnimation(forKey: key)
        
        return self
    }

    @discardableResult
    func ename(_ name: String?) -> Self {
        self.name = name
        
        return self
    }

    @discardableResult
    func edelegate(_ delegate: (any CALayerDelegate)?) -> Self {
        self.delegate = delegate
        
        return self
    }

    @discardableResult
    func estyle(_ style: [AnyHashable : Any]?) -> Self {
        self.style = style
        
        return self
    }
}
