//
//  WebViewSnapshot.swift
//  PhotoStitch2
//
//  Created by Azuby on 18/3/26.
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

    func capture(webView: WebViewSnapshotView) async throws -> UIImage {
        guard let hider = VIEW_CONTROLLER.view.snapshotView(afterScreenUpdates: true) else {
            throw MainError.error("Cant overlay snapshot")
        }

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

        VIEW_CONTROLLER.startLoading(String(localized: "Website Capturing...   \(0)%"))

        await runJS(webView, "document.documentElement.style.overflow = 'hidden'; document.body.style.overflow = 'hidden';")

        let height = await contentHeight(of: webView)
        let eachHeight = round(webView.bounds.height / 3)
        let count = max(Int(ceil((height - (webView.bounds.height - eachHeight)) / eachHeight)), 1)
        
        print(height)
        
        webView.frame = CGRect(origin: .zero, size: CGSize(width: webView.scrollView.contentSize.width, height: min(height, 2000)))
        
        var images = [UIImage]()

        for index in 0..<count {
            VIEW_CONTROLLER.startLoading(String(localized: "Website Capturing...   \(index * 100 / count)%"))

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

            await waitForContentLoaded(webView: webView)

            let image = try await webView.takeSnapshot(configuration: config)

            images.append(image)
        }

        await runJS(webView, "document.documentElement.style.overflow = ''; document.body.style.overflow = '';")

        let bounds = webView.bounds

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

        try await Task.sleep(for: .seconds(0.25))
        
        hider.removeFromSuperview()
        
        let image = await stitch(images: images, width: bounds.width * scale, height: height * scale)

        await withCheckedContinuation { continuation in
            VIEW_CONTROLLER.stopLoading {
                continuation.resume()
                VIEW_CONTROLLER.view.isUserInteractionEnabled = true
            }
        }

        return try image.unwrap()
    }

    // Safe async wrapper around evaluateJavaScript. (The built-in async
    // overload can crash when the script returns nil, so we bridge the
    // completion-based API ourselves.)
    @discardableResult
    private func runJS(_ webView: WKWebView, _ js: String) async -> Any? {
        await withCheckedContinuation { continuation in
            webView.evaluateJavaScript(js) { result, _ in
                continuation.resume(returning: result)
            }
        }
    }
    
    private func contentHeight(of webView: WKWebView) async -> CGFloat {
        let js = """
        const getMaxY = () => {
            let maxY = 0;
            for (const el of document.body.getElementsByTagName('*')) {
                const rect = el.getBoundingClientRect();
                const bottom = rect.bottom + window.scrollY;
                if (bottom > maxY && rect.height > 0) maxY = bottom;
            }
            return maxY;
        };

        return await new Promise(resolve => {
            const deadline = Date.now() + 10000;
            let last = 0, stable = 0;
            const check = () => {
                const y = getMaxY();
                if (y === last) stable++; else { stable = 0; last = y; }
                if (stable >= 3 || Date.now() > deadline) return resolve(y);
                setTimeout(check, 200);
            };
            check();
        });
        """
        let result = try? await webView.callAsyncJavaScript(js, contentWorld: .page)
        return (result as? NSNumber).map { CGFloat(truncating: $0) } ?? 0
    }

    private func waitForContentLoaded(webView: WKWebView, retries: Int = 5) async {
        var remaining = retries

        try? await Task.sleep(for: .seconds(0.25))
        
        while webView.isLoading && remaining > 0 {
            try? await Task.sleep(for: .seconds(0.25))
            remaining -= 1
        }
    }

    private func stitch(images: [UIImage], width: CGFloat, height: CGFloat) async -> UIImage? {
        guard !images.isEmpty, width > 0, height > 0 else { return nil }

        return await Task.detached(priority: .userInitiated) {
            let format = UIGraphicsImageRendererFormat()
            format.scale = 1
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: format)

            var currHeight = CGFloat.zero

            return renderer.image { _ in
                images.forEach { image in
                    let height = width * image.size.height / image.size.width
                    image.draw(in: CGRect(x: 0, y: currHeight, width: width, height: height))
                    currHeight += height
                }
            }
        }.value
    }
}
