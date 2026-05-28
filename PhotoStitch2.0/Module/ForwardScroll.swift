//
//  ForwardScrollScroll.swift
//  ModuleTest
//
//  Created by TapUniverse Dev9 on 17/04/2024.
//

import UIKit

protocol ForwardScrollProtocol: UIView {
    func passInteration(at point: CGPoint) -> Bool
}

/**
 A scrollview that auto pass touch to passView when cancel. Zoom handle for ForwardScroll.
 - Important: Set passView to ForwardScroll instance for this work.
 */
class ForwardScroll: UIScrollView {
    var passViews: [ForwardScrollProtocol] = []
    
    private var onDraw = false
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    private func commonInit() {
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        maximumZoomScale = 100
        delaysContentTouches = false
    }

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        for passView in passViews {
            if gestureRecognizer.numberOfTouches == 1,
               passView.passInteration(at: gestureRecognizer.location(in: passView))
            {
                setContentOffset(contentOffset, animated: false)
                setZoomScale(zoomScale, animated: false)
                if let d = delegate {
                    d.scrollViewDidEndZooming?(self, with: nil, atScale: 0)
                }
                return false
            }
        }
        
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for passView in passViews {
            if let point = touches.first?.location(in: passView),
               passView.passInteration(at: point)
            {
                passView.touchesBegan(touches, with: event)
                break
            }
        }
        
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for passView in passViews {
            if let point = touches.first?.location(in: passView),
               passView.passInteration(at: point)
            {
                passView.touchesMoved(touches, with: event)
                break
            }
        }
        
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for passView in passViews {
            passView.touchesEnded(touches, with: event)
        }
        
        super.touchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for passView in passViews {
            passView.touchesCancelled(touches, with: event)
        }
        
        super.touchesCancelled(touches, with: event)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return true
    }
}
