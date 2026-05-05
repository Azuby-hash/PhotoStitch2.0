//
//  UIStackViewHighlight.swift
//  BackgroundEraser2.0
//
//  Created by Tap Dev5 on 16/09/2022.
//

import UIKit

class UIStackViewHighlight: UIStackView {
    
    @IBInspectable var buttonClickColor: UIColor = UIColor.white
    @IBInspectable var buttonUnClickColor: UIColor = UIColor.black
    
    @IBInspectable var iconClickColor: UIColor = UIColor.white
    @IBInspectable var iconUnClickColor: UIColor = UIColor.white
    @IBInspectable var scaleX100: CGFloat = 100
    @IBInspectable var notification: String = ""
    
    @IBInspectable var selectFirst: Bool = true
    
    private var didLoad = false
    private(set) var index = 0
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if didLoad {
            return
        }
        didLoad = true
        
        for segment in arrangedSubviews {
            segment.gestureRecognizers = [UITapGestureRecognizer(target: self, action: #selector(switchType))]
        }
        
        if selectFirst {
            if let ges = arrangedSubviews.first?.gestureRecognizers?.first as? UITapGestureRecognizer {
                switchType(g: ges)
            }
        }
    }
    @objc func switchType(g: UITapGestureRecognizer) {
        guard let view = g.view else { return }

        for button in arrangedSubviews.enumerated() {
            if button.element == view {
                if !notification.isEmpty {
                    NotificationCenter.default.post(name: NSNotification.Name(notification), object: button)
                }
            }
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.curveEaseInOut, .allowUserInteraction]) { [self] in
            
            for button in arrangedSubviews.enumerated() {
                if button.element == view {
                    index = button.offset
                }
                let button = button.element
                button.backgroundColor = button == view ? buttonClickColor : buttonUnClickColor
                
                if let stack = button.subviews.first as? UIStackView {
                    for v in stack.arrangedSubviews {
                        v.tintColor = button == view ? iconClickColor : iconUnClickColor
                        if let label = v as? UILabel {
                            UIView.transition(with: label, duration: 0.25, options: .transitionCrossDissolve) { [self] in
                                label.textColor = button == view ? iconClickColor : iconUnClickColor
                            }
                        }
                    }
                } else {
                    button.subviews.first?.tintColor = button == view ? iconClickColor : iconUnClickColor
                    if let label = button.subviews.first as? UILabel {
                        UIView.transition(with: label, duration: 0.25, options: .transitionCrossDissolve) { [self] in
                            label.textColor = button == view ? iconClickColor : iconUnClickColor
                        }
                    }
                }
                button.transform = button == view ? .identity.scaledBy(x: scaleX100 / 100, y: scaleX100 / 100) : .identity
            }
            layoutIfNeeded()
        }
        
    }
    
    func deselect() {
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut) { [self] in
            
            for button in arrangedSubviews {
                button.backgroundColor = buttonUnClickColor
                button.subviews.first?.tintColor = iconUnClickColor
                button.transform = .identity
            }
            layoutIfNeeded()
        }
    }
}

class UIStackViewBiggerPoint: UIStackView {
    @IBInspectable var inset: CGPoint = .init(x: -10, y: -10)
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let rect = self.bounds.insetBy(dx: inset.x, dy: inset.y)
        var isTouch = false
        for subview in subviews {
            if subview.point(inside: convert(point, to: subview), with: event) {
                isTouch = true
                break
            }
        }
        
        return rect.contains(point) || isTouch
    }
}
