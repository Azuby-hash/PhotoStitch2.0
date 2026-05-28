import UIKit

/**
 This class acts as a custom gesture coordinator from touches event, providing functionality identical to a `UIPanGestureRecognizer`.
 
 It intercepts raw touch events (`touchesBegan`, `touchesMoved`, etc.) and calculates the translation
 and state of the gesture relative to a target subview. This is particularly useful for managing
 interactions across multiple stitched image layers within a single coordinate space.
 */
class TouchGesture {
    private var containerView: UIView
    private var startingPoint: CGPoint?
    private var activeTouch: UITouch = UITouch()
    private var totalTranslation: CGPoint = .zero

    private(set) var state: UIGestureRecognizer.State = .began
    private(set) var view: UIView?
    
    fileprivate init(container: UIView) {
        self.containerView = container
    }
    
    // MARK: - Reverted Method Names
    
    func location(in coordinateSpace: UIView) -> CGPoint {
        return activeTouch.location(in: coordinateSpace)
    }
    
    func translation(in coordinateSpace: UIView) -> CGPoint {
        return containerView.convert(totalTranslation, to: coordinateSpace) - containerView.convert(CGPoint.zero, to: coordinateSpace)
    }
    
    // MARK: - Getters & Setters
    
    func getStartingPoint() -> CGPoint? {
        return startingPoint
    }

    func getActiveTouch() -> UITouch {
        return activeTouch
    }
    
    func getTotalTranslation() -> CGPoint {
        return totalTranslation
    }
    
    fileprivate func setStartingPoint(_ point: CGPoint?) {
        self.startingPoint = point
    }
    
    fileprivate func setGestureState(_ state: UIGestureRecognizer.State) {
        self.state = state
    }
    
    fileprivate func setTargetedView(_ view: UIView?) {
        self.view = view
    }
    
    fileprivate func setActiveTouch(_ touch: UITouch) {
        self.activeTouch = touch
    }
    
    fileprivate func setTotalTranslation(_ translation: CGPoint) {
        self.totalTranslation = translation
    }
}

/**
 This class acts as a custom gesture coordinator from touches event, providing functionality identical to a `UIPanGestureRecognizer`.
 
 It intercepts raw touch events (`touchesBegan`, `touchesMoved`, etc.) and calculates the translation
 and state of the gesture relative to a target subview. This is particularly useful for managing
 interactions across multiple stitched image layers within a single coordinate space.
 */
class TouchView: UIView {
    private var currentTouch: TouchGesture?
    private var currentActionHandler: ((TouchGesture) -> Void)?
    private var gestureMappings: Zip2Sequence<[UIView], [(TouchGesture) -> Void]> = zip([], [])
    
    // MARK: - Accessors
    
    func getCurrentTouch() -> TouchGesture? {
        return currentTouch
    }
    
    func setGestureMappings(_ mappings: Zip2Sequence<[UIView], [(TouchGesture) -> Void]>) {
        self.gestureMappings = mappings
    }
    
    // MARK: - Touch Overrides
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let firstTouch = touches.first else { return }
        
        let touchLocation = firstTouch.location(in: self)
        
        for (view, handler) in gestureMappings {
            if view.convert(view.bounds, to: self).contains(touchLocation) {
                let touch = TouchGesture(container: self)
                touch.setTargetedView(view)
                touch.setActiveTouch(firstTouch)
                touch.setGestureState(.began)
                touch.setStartingPoint(touchLocation)
                
                self.currentTouch = touch
                self.currentActionHandler = handler
                
                handler(touch)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard let touch = currentTouch,
              let updatedTouch = touches.first(where: { $0 == touch.getActiveTouch() }),
              let origin = touch.getStartingPoint(),
              let handler = currentActionHandler
        else { return }
        
        let newLocation = updatedTouch.location(in: self)
        
        touch.setActiveTouch(updatedTouch)
        touch.setGestureState(.changed)
        touch.setTotalTranslation(newLocation - origin)
        
        handler(touch)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard let touch = currentTouch,
              let updatedTouch = touches.first(where: { $0 == touch.getActiveTouch() }),
              let origin = touch.getStartingPoint(),
              let handler = currentActionHandler
        else { return }
        
        let finalLocation = updatedTouch.location(in: self)
        
        touch.setActiveTouch(updatedTouch)
        touch.setGestureState(.ended)
        touch.setTotalTranslation(finalLocation - origin)
        
        handler(touch)
        resetInteractionState()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        guard let touch = currentTouch,
              let handler = currentActionHandler
        else { return }
        
        touch.setGestureState(.cancelled)
        handler(touch)
        resetInteractionState()
    }
    
    private func resetInteractionState() {
        self.currentTouch = nil
        self.currentActionHandler = nil
    }
}
