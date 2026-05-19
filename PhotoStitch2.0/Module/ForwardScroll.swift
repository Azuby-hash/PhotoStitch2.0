//
//  ForwardScrollScroll.swift
//  ModuleTest
//
//  Created by TapUniverse Dev9 on 17/04/2024.
//

import UIKit

protocol ForwardScrollDelegate: AnyObject {
    func updateZoom(zoomScale: CGFloat, contentOffset: CGPoint)
}

/**
 A scrollview that auto pass touch to passView when cancel. Zoom handle for ForwardScroll.
 - Important: Set flow and passView to ForwardScroll instance for this work.
 */
class ForwardScroll: UIScrollView {
    weak var zoomTrack: ForwardScrollDelegate?
    weak var passView: UIView?
    
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
        delaysContentTouches = false
    }
    
    private func updateFlow() {
        zoomTrack?.updateZoom(zoomScale: zoomScale, contentOffset: contentOffset)
    }
    
    override var zoomScale: CGFloat {
        didSet {
            updateFlow()
        }
    }
    
    override var contentOffset: CGPoint {
        didSet {
            updateFlow()
        }
    }
    
    override func setZoomScale(_ scale: CGFloat, animated: Bool) {
        super.setZoomScale(scale, animated: animated)
        
        updateFlow()
    }
    
    override func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        super.setContentOffset(contentOffset, animated: animated)
        
        updateFlow()
    }

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let passView = passView,
           gestureRecognizer.numberOfTouches == 1,
           passView.point(inside: gestureRecognizer.location(in: passView), with: nil)
        {
            setContentOffset(contentOffset, animated: false)
            setZoomScale(zoomScale, animated: false)
            if let d = delegate {
                d.scrollViewDidEndZooming?(self, with: nil, atScale: 0)
            }
            return false
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let passView = passView,
           let point = touches.first?.location(in: passView),
           passView.point(inside: point, with: nil)
        {
            passView.touchesBegan(touches, with: event)
            onDraw = true
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let passView = passView,
           let point = touches.first?.location(in: passView),
           passView.point(inside: point, with: nil),
           !onDraw
        {
            passView.touchesBegan(touches, with: event)
            onDraw = true
            return
        }

        passView?.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        onDraw = false
        passView?.touchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        onDraw = false
        passView?.touchesCancelled(touches, with: event)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return true
    }
}
