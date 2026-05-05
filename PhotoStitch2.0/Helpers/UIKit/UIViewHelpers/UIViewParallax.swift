//
//  UIViewParallax.swift
//  BackgroundEraser2.0
//
//  Created by Tap Dev5 on 19/05/2023.
//

import UIKit

class UIViewParallax: UIView {
    @IBInspectable var amount: CGFloat = 20
    @IBInspectable var dragAble: Bool = false
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        addParallaxToView(amount)
        
        if dragAble {
            gestureRecognizers = [UIPanGestureRecognizer(target: self, action: #selector(pan))]
        }
    }
    
    @objc func pan(g: UIPanGestureRecognizer) {
        transform = .identity.translatedBy(x: g.translation(in: self).x, y: g.translation(in: self).y)
        
        if g.state == .ended {
            UIView.animate(withDuration: 1, delay: 0.5, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut) { [self] in
                transform = .identity
            }
        }
    }
}

extension UIView {

    func addParallaxToView(_ amount: CGFloat = 20) {
        let amount = amount

        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = -amount
        horizontal.maximumRelativeValue = amount

        let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        vertical.minimumRelativeValue = -amount
        vertical.maximumRelativeValue = amount

        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontal, vertical]
        addMotionEffect(group)
    }

}
