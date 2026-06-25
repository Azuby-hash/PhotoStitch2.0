//
//  LoadingManager.swift
//  Sticker Maker
//
//  Created by Azuby on 2/19/26.
//

import UIKit
import LinkPresentation
import UniformTypeIdentifiers

extension UIViewController {
    func startLoading(_ title: String? = "Loading...") {
        if let loading = presentedViewController as? UIAlertController {
            loading.title = title
            return
        }

        let loadingAlert = UIAlertController(title: title, message: "\n\n", preferredStyle: .alert)
        loadingAlert.addSpinner()
        present(loadingAlert, animated: true)
    }
    
    func stopLoading(completion: (() -> Void)? = nil) {
        (presentedViewController as? UIAlertController)?.dismiss(animated: true) {
            completion?()
        }
    }
    
    func startAlert(_ title: String? = nil, _ message: String? = nil, _ primary: String? = nil, primaryAction: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        if let primary = primary {
            alert.addAction(UIAlertAction(title: primary, style: .default, handler: { _ in primaryAction() }))
        }
        
        present(alert, animated: true)
    }
    
    func startNoti(_ title: String? = nil, _ message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            alert.dismiss(animated: true)
        }
    }
}

protocol ShareItem: NSObject, UIActivityItemSource {
    var data: Data { get }
}

class ImageItem: NSObject, ShareItem {
    private(set) var data: Data
    private(set) var link: LPLinkMetadata
    
    init(data: Data) {
        self.data = data
        self.link = LPLinkMetadata()
        
        if let img = UIImage(data: data) {
            link.iconProvider = NSItemProvider(object: img)
            link.imageProvider = NSItemProvider(object: img)
        }
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return data
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return data
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        return link
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?) -> String {
        return UTType.image.identifier
    }
}

fileprivate extension UIAlertController {
    func addSpinner() {
        let activity: UIActivityIndicatorView = UIActivityIndicatorView(style: .large)
        view.addSubview(activity)

        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.addConstraint(NSLayoutConstraint(item: activity, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: activity.bounds.size.width))
        activity.addConstraint(NSLayoutConstraint(item: activity, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: activity.bounds.size.height))
        view.addConstraint(NSLayoutConstraint(item: activity, attribute: .centerXWithinMargins, relatedBy: .equal, toItem: view, attribute: .centerXWithinMargins, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: activity, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottomMargin, multiplier: 1.0, constant: -20.0))

        activity.startAnimating()
    }
}
