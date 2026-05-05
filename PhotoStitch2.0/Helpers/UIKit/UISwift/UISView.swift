//
//  UISView.swift
//  StitchPhotos2.0
//
//  Created by TapUniverse Dev9 on 12/3/26.
//

import UIKit

extension UIView {
    @discardableResult
    func elayerModifier<L: CALayer>(_ modifier: (L) -> Void) -> Self {
        if let layer = self.layer as? L {
            modifier(layer)
        }
        
        return self
    }
    
    @discardableResult
    func esubviewsModifier(_ modifier: ([UIView]) -> Void) -> Self {
        modifier(subviews)
        
        return self
    }
    
    @discardableResult
    func eselfConstraints(_ constraints: [SelfConstraint]) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        
        // 1. Create a collection to hold constraints
        var anchorsToActivate = [NSLayoutConstraint]()

        constraints.forEach { constraint in
            switch constraint {
            case .width(let constant, let priority):
                anchorsToActivate.append(widthAnchor.constraint(equalToConstant: constant).epriority(priority))
                
            case .height(let constant, let priority):
                anchorsToActivate.append(heightAnchor.constraint(equalToConstant: constant).epriority(priority))
            }
        }

        // 2. Activate everything once for better performance
        NSLayoutConstraint.activate(anchorsToActivate, compareConstrants: self.constraints)
        
        return self
    }
    
    @discardableResult
    func eaddSubview(_ view: UIView, _ constraints: [Constraint] = []) -> Self {
        addSubview(view)
        
        setupConstraints(constraints, from: view)
        
        return self
    }
    
    @discardableResult
    func eaddConstraints(to view: UIView, _ constraints: [Constraint] = []) -> Self {
        setupConstraints(constraints, from: view)
        
        return self
    }
    
    @discardableResult
    func einsertSubview(_ view: UIView, at index: Int, _ constraints: [Constraint] = []) -> Self {
        insertSubview(view, at: index)
        
        setupConstraints(constraints, from: view)
        
        return self
    }
    
    @discardableResult
    func einsertSubview(_ view: UIView, belowSubview siblingSubview: UIView, _ constraints: [Constraint] = []) -> Self {
        insertSubview(view, belowSubview: siblingSubview)
        
        setupConstraints(constraints, from: view)
        
        return self
    }
    
    @discardableResult
    func einsertSubview(_ view: UIView, aboveSubview siblingSubview: UIView, _ constraints: [Constraint] = []) -> Self {
        insertSubview(view, aboveSubview: siblingSubview)
        
        setupConstraints(constraints, from: view)
        
        return self
    }
    
    @discardableResult
    func eframe(_ frame: CGRect) -> Self {
        self.frame = frame
        
        return self
    }
    
    @discardableResult
    func etintColor(_ color: UIColor) -> Self {
        tintColor = color
        
        return self
    }
    
    @discardableResult
    func ebackgroundColor(_ color: UIColor) -> Self {
        backgroundColor = color
        
        return self
    }
    
    @discardableResult
    func eclipsToBounds(_ clipsToBounds: Bool) -> Self {
        self.clipsToBounds = clipsToBounds
        
        return self
    }
    
    @discardableResult
    func eisUserInteractionEnabled(_ isUserInteractionEnabled: Bool) -> Self {
        self.isUserInteractionEnabled = isUserInteractionEnabled
        
        return self
    }
    
    @discardableResult
    func ealpha(_ alpha: CGFloat) -> Self {
        self.alpha = alpha
        
        return self
    }
    
    @discardableResult
    func eisHidden(_ isHidden: Bool) -> Self {
        self.isHidden = isHidden
        
        return self
    }
    
    @discardableResult
    func econtentMode(_ contentMode: UIView.ContentMode) -> Self {
        self.contentMode = contentMode
        
        return self
    }
    
    @discardableResult
    func emask(_ mask: UIView?) -> Self {
        self.mask = mask
        
        return self
    }
    
    @discardableResult
    func etintAdjustmentMode(_ tintAdjustmentMode: UIView.TintAdjustmentMode) -> Self {
        self.tintAdjustmentMode = tintAdjustmentMode
        
        return self
    }
    
    @discardableResult
    func egestureRecognizers(_ gestureRecognizers: [UIGestureRecognizer]?) -> Self {
        self.gestureRecognizers = gestureRecognizers
        
        return self
    }
    
    @discardableResult
    func eaddGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) -> Self {
        addGestureRecognizer(gestureRecognizer)
        
        return self
    }
    
    @discardableResult
    func eremoveGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) -> Self {
        removeGestureRecognizer(gestureRecognizer)
        
        return self
    }
    
    @discardableResult
    func eaddMotionEffect(_ effect: UIMotionEffect) -> Self {
        addMotionEffect(effect)
        
        return self
    }
    
    @discardableResult
    func eremoveMotionEffect(_ effect: UIMotionEffect) -> Self {
        removeMotionEffect(effect)
        
        return self
    }
    
    @discardableResult
    func eremoveConstraint(_ constraint: NSLayoutConstraint) -> Self {
        removeConstraint(constraint)
        
        return self
    }
    
    @discardableResult
    func eremoveConstraints(_ constraints: [NSLayoutConstraint]) -> Self {
        removeConstraints(constraints)
        
        return self
    }
    
    @discardableResult
    func etranslatesAutoresizingMaskIntoConstraints(_ translatesAutoresizingMaskIntoConstraints: Bool) -> Self {
        self.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints
        
        return self
    }
    
    @discardableResult
    func eoverrideUserInterfaceStyle(_ overrideUserInterfaceStyle: UIUserInterfaceStyle) -> Self {
        self.overrideUserInterfaceStyle = overrideUserInterfaceStyle
        
        return self
    }
    
    @discardableResult
    func esetContentHuggingPriority(_ priority: UILayoutPriority, for axis: NSLayoutConstraint.Axis) -> Self {
        setContentHuggingPriority(priority, for: axis)
        
        return self
    }

    @discardableResult
    func esetContentCompressionResistancePriority(_ priority: UILayoutPriority, for axis: NSLayoutConstraint.Axis) -> Self {
        setContentCompressionResistancePriority(priority, for: axis)
        
        return self
    }
}
