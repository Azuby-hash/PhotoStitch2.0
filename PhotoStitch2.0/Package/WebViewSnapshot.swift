//
//  WebViewSnapshot.swift
//  StitchPhotos2.0
//
//  Created by TapUniverse Dev9 on 18/3/26.
//

import UIKit
import WebKit

class WebViewSnapshotView: WKWebView {
    func fontZoom(percent: Int) {
        let js = "document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='\(percent)%'"
        evaluateJavaScript(js) { _, _ in }
    }
}

class WebViewSnapshot {
    static let shared = WebViewSnapshot()
    
    func capture(webView: WebViewSnapshotView, completion: @escaping (UIImage) -> Void, doneUI: @escaping () -> Void) {
        guard let hider = VIEW_CONTROLLER.view.snapshotView(afterScreenUpdates: true) else { return }

        VIEW_CONTROLLER.view.addSubview(hider)

        let contentOffset = webView.scrollView.contentOffset
        let zoomScale = webView.scrollView.zoomScale
        let scale = UIScreen.main.scale

        webView.translatesAutoresizingMaskIntoConstraints = true
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.showsVerticalScrollIndicator = false

        if #available(iOS 26.0, *) {
            webView.scrollView.topEdgeEffect.isHidden = true
            webView.scrollView.bottomEdgeEffect.isHidden = true
            webView.scrollView.leftEdgeEffect.isHidden = true
            webView.scrollView.rightEdgeEffect.isHidden = true
        }

        VIEW_CONTROLLER.startLoading("Website Capturing...   0%")

        webView.evaluateJavaScript("document.documentElement.style.overflow = 'hidden'; document.body.style.overflow = 'hidden';")

        let height = webView.scrollView.contentSize.height - webView.scrollView.contentInset.top - webView.scrollView.contentInset.bottom
        let eachHeight = round(webView.bounds.height / 3)
        let count = Int(ceil((height - (webView.bounds.height - eachHeight)) / eachHeight))
        
        webView.frame = CGRect(origin: .zero, size: CGSize(width: webView.scrollView.contentSize.width, height: min(webView.scrollView.contentSize.height - webView.scrollView.contentInset.top - webView.scrollView.contentInset.bottom, 2000)))
        
        var images = [UIImage]()
        
        func snapshot(at index: Int) {
            DispatchQueue.main.async {
                VIEW_CONTROLLER.startLoading("Website Capturing...   \(index * 100 / count)%")
            }
            
            if index == count {
                webView.evaluateJavaScript("document.documentElement.style.overflow = ''; document.body.style.overflow = '';")
                webView.scrollView.contentOffset = contentOffset
                webView.scrollView.zoomScale = zoomScale
                webView.translatesAutoresizingMaskIntoConstraints = false
                webView.scrollView.showsHorizontalScrollIndicator = true
                webView.scrollView.showsVerticalScrollIndicator = true
                
                if #available(iOS 26.0, *) {
                    webView.scrollView.topEdgeEffect.isHidden = false
                    webView.scrollView.bottomEdgeEffect.isHidden = false
                    webView.scrollView.leftEdgeEffect.isHidden = false
                    webView.scrollView.rightEdgeEffect.isHidden = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    hider.removeFromSuperview()
                }
                
                let bounds = webView.bounds
                
                DispatchQueue.global(qos: .default).async {
                    let format = UIGraphicsImageRendererFormat()
                    format.scale = 1
                    let renderer = UIGraphicsImageRenderer(size: CGSize(width: bounds.width * scale, height: height * scale), format: format)
                    
                    var currHeight = CGFloat.zero
                    
                    let image = renderer.image(actions: { _ in
                        images.enumerated().forEach { (index, image) in
                            let height = bounds.width * scale * image.size.height / image.size.width
                            image.draw(in: CGRect(x: 0, y: currHeight, width: bounds.width * scale, height: height))
                            currHeight += height
                        }
                    })
                    
                    completion(image)

                    DispatchQueue.main.async {
                        VIEW_CONTROLLER.stopLoading {
                            doneUI()
                            VIEW_CONTROLLER.view.isUserInteractionEnabled = true
                        }
                    }
                }
                
                return
            }
            
            webView.scrollView.contentOffset = .init(x: 0, y: eachHeight * CGFloat(index))
            
            let config = WKSnapshotConfiguration()
            
            config.rect = CGRect(x: 0, y: (webView.bounds.height - eachHeight) / 2, width: webView.bounds.width, height: eachHeight)
            
            if index == 0 {
                config.rect = CGRect(x: 0, y: 0, width: webView.bounds.width, height: (webView.bounds.height + eachHeight) / 2)
            }
            
            if index == count - 1 {
                config.rect = CGRect(x: 0, y: (webView.bounds.height - eachHeight) / 2, width: webView.bounds.width, height: height - (webView.bounds.height - eachHeight) / 2 - eachHeight * CGFloat(index))
            }
            
            if index == 0 && index == count - 1 {
                config.rect = CGRect(x: 0, y: 0, width: webView.bounds.width, height: height)
            }
            
            waitForContentLoaded(webView: webView) {
                webView.takeSnapshot(with: config) { image, _ in
                    guard let image = image else {
                        return
                    }
                    
                    images.append(image)
                    
                    snapshot(at: index + 1)
                }
            }
        }
        
        snapshot(at: 0)
    }
    
    private func waitForContentLoaded(webView: WKWebView, retries: Int = 5, then next: @escaping () -> Void) {
        if !webView.isLoading {
            next()
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.waitForContentLoaded(webView: webView, retries: retries - 1, then: next)
        }
    }
}
