//
//  UIViewControllerPresent.swift
//  ModuleTest
//
//  Created by Azuby on 12/10/2023.
//

import UIKit

/**
 Custom present animation
 */
class CustomNavigationViewController: UIViewController, UIViewControllerTransitioningDelegate {
    /** Present as navigation push */
    func pushViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        viewController.transitioningDelegate = CustomNavigationPresent.shared
        CustomNavigationPresent.shared.presentType = .navigation
        
        present(viewController, animated: true, completion: completion)
    }
    
    func pushForwardViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        guard let present = presentingViewController as? CustomNavigationViewController,
              let snap = view.snapshotView(afterScreenUpdates: true)
        else { return }
        
        present.view.addSubview(snap)
        dismiss(animated: false) {
            present.pushViewController(viewController, animated: true, completion: completion)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                snap.removeFromSuperview()
            }
        }
    }
}

fileprivate class CustomNavigationPresent: NSObject, UIViewControllerTransitioningDelegate {
    static let shared = CustomNavigationPresent()
    
    var presentType = UCPType.navigation
    
    enum UCPType {
        case normal
        case navigation
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch (presentType) {
        case .navigation:
            return UCPNavigation(phase: .present)
        case .normal:
            return nil
        }
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch (presentType) {
        case .navigation:
            return UCPNavigation(phase: .dismiss)
        case .normal:
            return nil
        }
    }
}

fileprivate class UCPNavigation: NSObject, UIViewControllerAnimatedTransitioning {
    private let duration: TimeInterval = 0.5
    private var phase: UCPPhase = .present
    
    enum UCPPhase {
        case present
        case dismiss
    }
    
    init(phase: UCPPhase) {
        super.init()
        self.phase = phase
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else {
            return
        }
        
        let containerView = transitionContext.containerView
        
        var toVCX: CGFloat = 0
        var fromVCX: CGFloat = 0
        
        switch(phase) {
        case .present:
            toVCX = containerView.frame.size.width
            fromVCX = -containerView.bounds.midX
        case .dismiss:
            toVCX = -containerView.frame.size.width
            fromVCX = containerView.bounds.midX
        }

        // Set the initial position of the 'to' view to the right of the screen
        toVC.view.frame = CGRect(x: toVCX, y: 0, width: containerView.frame.size.width, height: containerView.frame.size.height)
        
        // Add the 'to' view to the container view
        containerView.addSubview(toVC.view)

        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
            fromVC.view.frame.origin.x = fromVCX
            toVC.view.frame = containerView.frame
        }) { (finished) in
            transitionContext.completeTransition(finished)
        }
    }
}
