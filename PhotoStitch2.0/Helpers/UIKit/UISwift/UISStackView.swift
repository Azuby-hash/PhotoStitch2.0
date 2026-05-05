//
//  UISStackView.swift
//  StitchPhotos2.0
//
//  Created by TapUniverse Dev9 on 12/3/26.
//

import UIKit

extension UIStackView {
    @discardableResult
    func eaxis(_ axis: NSLayoutConstraint.Axis) -> Self {
        self.axis = axis
        
        return self
    }
    
    @discardableResult
    func eaddArrangedSubview(_ view: UIView, _ constraints: [Constraint] = []) -> Self {
        addArrangedSubview(view)
        
        setupConstraints(constraints, from: view)
        
        return self
    }
    
    @discardableResult
    func einsertArrangedSubview(_ view: UIView, at index: Int, _ constraints: [Constraint] = []) -> Self {
        insertArrangedSubview(view, at: index)
        
        setupConstraints(constraints, from: view)
        
        return self
    }
    
    @discardableResult
    func edistribution(_ distribution: UIStackView.Distribution) -> Self {
        self.distribution = distribution
        
        return self
    }

    @discardableResult
    func ealignment(_ alignment: UIStackView.Alignment) -> Self {
        self.alignment = alignment
        
        return self
    }

    @discardableResult
    func espacing(_ spacing: CGFloat) -> Self {
        self.spacing = spacing
        
        return self
    }

    @discardableResult
    func esetCustomSpacing(_ spacing: CGFloat, after arrangedSubview: UIView) -> Self {
        setCustomSpacing(spacing, after: arrangedSubview)
        
        return self
    }
}
