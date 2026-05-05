//
//  UIViewControllerStoryboard.swift
//  AIVideoGenerator
//
//  Created by TapUniverse Dev9 on 01/04/2024.
//

import UIKit

extension UIViewController {
    static func create(id: String = "main") -> UIViewController {
        return UIStoryboard(name: String(describing: self), bundle: nil).instantiateViewController(withIdentifier: id)
    }
    
    static func createNavigation(id: String = "main") -> UINavigationController {
        let viewController = UIStoryboard(name: String(describing: self), bundle: nil).instantiateViewController(withIdentifier: id)
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.isNavigationBarHidden = true
        navigationController.isToolbarHidden = true
        navigationController.modalPresentationStyle = .fullScreen
        
        return navigationController
    }
}

/**
 ```
 func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
     return supportOrientations
 }
 ```
 */
var supportOrientations: UIInterfaceOrientationMask = [.portrait]

extension UIViewController {
    /**
     ```
     func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
         return supportOrientations
     }
     ```
     */
    func correctOrientation() {
        supportOrientations = supportedInterfaceOrientations
        
        if #available(iOS 16.0, *) {
            setNeedsUpdateOfSupportedInterfaceOrientations()
        } else {
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
    
    /**
     ```
     func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
         return supportOrientations
     }
     ```
     */
    func correctPresentingOrientation() {
        supportOrientations = presentingViewController?.supportedInterfaceOrientations ?? supportOrientations
        
        if #available(iOS 16.0, *) {
            setNeedsUpdateOfSupportedInterfaceOrientations()
        } else {
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
}

extension UIViewController {
    func embed(to view: UIView, in viewController: UIViewController) {
        viewController.addChild(self)
        willMove(toParent: viewController)
        self.view.frame = view.bounds
        view.addSubview(self.view)
        didMove(toParent: viewController)
    }
    
    func disEmbed() {
        willMove(toParent: nil)
        view.removeFromSuperview()
    }
}
