//
//  UISConstraints.swift
//  StitchPhotos2.0
//
//  Created by TapUniverse Dev9 on 12/3/26.
//

import UIKit

enum Constraint: Equatable {
    case leading(CGFloat, Float = 1000)
    case trailing(CGFloat, Float = 1000)
    case top(CGFloat, Float = 1000)
    case bottom(CGFloat, Float = 1000)
    case centerX(CGFloat, Float = 1000)
    case centerY(CGFloat, Float = 1000)
    case width(CGFloat, Float = 1000)
    case height(CGFloat, Float = 1000)
}

enum SelfConstraint: Equatable {
    case width(CGFloat, Float = 1000)
    case height(CGFloat, Float = 1000)
}

extension UIView {
    func setupConstraints(_ constraints: [Constraint], from view: UIView) {
        if !constraints.isEmpty {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // 1. Create a collection to hold constraints
        var anchorsToActivate = [NSLayoutConstraint]()

        constraints.forEach { constraint in
            switch constraint {
            // Use 'let constant' to bind the value from the enum
            case .leading(let constant, let priority):
                anchorsToActivate.append(view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: constant).epriority(priority))
                
            case .trailing(let constant, let priority):
                anchorsToActivate.append(trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: constant).epriority(priority))
                
            case .top(let constant, let priority):
                anchorsToActivate.append(view.topAnchor.constraint(equalTo: topAnchor, constant: constant).epriority(priority))
                
            case .bottom(let constant, let priority):
                anchorsToActivate.append(bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: constant).epriority(priority))
                
            case .centerX(let constant, let priority):
                anchorsToActivate.append(view.centerXAnchor.constraint(equalTo: centerXAnchor, constant: constant).epriority(priority))
                
            case .centerY(let constant, let priority):
                anchorsToActivate.append(view.centerYAnchor.constraint(equalTo: centerYAnchor, constant: constant).epriority(priority))
                
            case .width(let constant, let priority):
                anchorsToActivate.append(view.widthAnchor.constraint(equalTo: widthAnchor, constant: constant).epriority(priority))
                
            case .height(let constant, let priority):
                anchorsToActivate.append(view.heightAnchor.constraint(equalTo: heightAnchor, constant: constant).epriority(priority))
            }
        }

        // 2. Activate everything once for better performance
        NSLayoutConstraint.activate(anchorsToActivate, compareConstrants: self.constraints + view.constraints)
    }
}

extension NSLayoutConstraint {
    @discardableResult
    func epriority(_ priority: Float) -> Self {
        self.priority = UILayoutPriority(priority)
        
        return self
    }
    
    static func activate(_ constraints: [NSLayoutConstraint], compareConstrants: [NSLayoutConstraint]) {
        constraints.forEach { constraint in
            if let activedConstraint = compareConstrants.first(where: { $0.firstAnchor == constraint.firstAnchor && $0.secondAnchor == constraint.secondAnchor }) {
                activedConstraint.isActive = false
            }
            
            NSLayoutConstraint.activate([constraint])
        }
    }
}
