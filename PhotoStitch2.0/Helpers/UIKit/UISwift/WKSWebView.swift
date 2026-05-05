//
//  WKSWebView.swift
//  StitchPhotos2.0
//
//  Created by TapUniverse Dev9 on 12/3/26.
//

import UIKit
import WebKit

extension WKWebView {
    @discardableResult
    func enavigationDelegate(_ navigationDelegate: (any WKNavigationDelegate)?) -> Self {
        self.navigationDelegate = navigationDelegate
        return self
    }
    
    @discardableResult
    func euiDelegate(_ uiDelegate: (any WKUIDelegate)?) -> Self {
        self.uiDelegate = uiDelegate
        return self
    }
    
    @discardableResult
    func emediaType(_ mediaType: String?) -> Self {
        self.mediaType = mediaType
        return self
    }
    
    @discardableResult
    func einteractionState(_ interactionState: Any?) -> Self {
        self.interactionState = interactionState
        return self
    }
    
    @discardableResult
    func eunderPageBackgroundColor(_ underPageBackgroundColor: UIColor!) -> Self {
        self.underPageBackgroundColor = underPageBackgroundColor
        return self
    }
    
    @discardableResult
    func eallowsBackForwardNavigationGestures(_ allowsBackForwardNavigationGestures: Bool) -> Self {
        self.allowsBackForwardNavigationGestures = allowsBackForwardNavigationGestures
        return self
    }
    
    @discardableResult
    func ecustomUserAgent(_ customUserAgent: String?) -> Self {
        self.customUserAgent = customUserAgent
        return self
    }
    
    @discardableResult
    func eallowsLinkPreview(_ allowsLinkPreview: Bool) -> Self {
        self.allowsLinkPreview = allowsLinkPreview
        return self
    }
    
    @discardableResult
    func epageZoom(_ pageZoom: CGFloat) -> Self {
        self.pageZoom = pageZoom
        return self
    }
    
    @available(iOS 16.0, *)
    @discardableResult
    func eisFindInteractionEnabled(_ isFindInteractionEnabled: Bool) -> Self {
        self.isFindInteractionEnabled = isFindInteractionEnabled
        return self
    }

    @available(iOS 16.4, *)
    @discardableResult
    func eisInspectable(_ isInspectable: Bool) -> Self {
        self.isInspectable = isInspectable
        return self
    }
    
    @discardableResult
    func estopLoading() -> Self {
        self.stopLoading()
        return self
    }
    
    @discardableResult
    func eevaluateJavaScript(_ javaScriptString: String, completionHandler: (@MainActor @Sendable (Any?, (any Error)?) -> Void)? = nil) -> Self {
        self.evaluateJavaScript(javaScriptString, completionHandler: completionHandler)
        return self
    }
    
    @discardableResult
    func ecloseAllMediaPresentations(completionHandler: (@MainActor @Sendable () -> Void)? = nil) -> Self {
        self.closeAllMediaPresentations(completionHandler: completionHandler)
        return self
    }
    
    @discardableResult
    func epauseAllMediaPlayback(completionHandler: (@MainActor @Sendable () -> Void)? = nil) -> Self {
        self.pauseAllMediaPlayback(completionHandler: completionHandler)
        return self
    }
    
    @discardableResult
    func esetAllMediaPlaybackSuspended(_ suspended: Bool, completionHandler: (@MainActor @Sendable () -> Void)? = nil) -> Self {
        self.setAllMediaPlaybackSuspended(suspended, completionHandler: completionHandler)
        return self
    }
    
    @discardableResult
    func erequestMediaPlaybackState(completionHandler: @escaping @MainActor @Sendable (WKMediaPlaybackState) -> Void) -> Self {
        self.requestMediaPlaybackState(completionHandler: completionHandler)
        return self
    }
    
    @discardableResult
    func esetCameraCaptureState(_ state: WKMediaCaptureState, completionHandler: (@MainActor @Sendable () -> Void)? = nil) -> Self {
        self.setCameraCaptureState(state, completionHandler: completionHandler)
        return self
    }
    
    @discardableResult
    func esetMicrophoneCaptureState(_ state: WKMediaCaptureState, completionHandler: (@MainActor @Sendable () -> Void)? = nil) -> Self {
        self.setMicrophoneCaptureState(state, completionHandler: completionHandler)
        return self
    }
    
    @discardableResult
    func etakeSnapshot(with snapshotConfiguration: WKSnapshotConfiguration?, completionHandler: @escaping @MainActor @Sendable (UIImage?, (any Error)?) -> Void) -> Self {
        self.takeSnapshot(with: snapshotConfiguration, completionHandler: completionHandler)
        return self
    }
    
    @discardableResult
    func estartDownload(using request: URLRequest, completionHandler: @escaping @MainActor @Sendable (WKDownload) -> Void) -> Self {
        self.startDownload(using: request, completionHandler: completionHandler)
        return self
    }
    
    @discardableResult
    func eresumeDownload(fromResumeData resumeData: Data, completionHandler: @escaping @MainActor @Sendable (WKDownload) -> Void) -> Self {
        self.resumeDownload(fromResumeData: resumeData, completionHandler: completionHandler)
        return self
    }

    @available(iOS 15.5, *)
    @discardableResult
    func esetMinimumViewportInset(_ minimumViewportInset: UIEdgeInsets, maximumViewportInset: UIEdgeInsets) -> Self {
        self.setMinimumViewportInset(minimumViewportInset, maximumViewportInset: maximumViewportInset)
        return self
    }

    @available(iOS 26.0, *)
    @discardableResult
    func efetchData(of dataTypes: WKWebViewDataType, completionHandler: @escaping @MainActor @Sendable (Data?, (any Error)?) -> Void) -> Self {
        self.fetchData(of: dataTypes, completionHandler: completionHandler)
        return self
    }

    @available(iOS 26.0, *)
    @discardableResult
    func erestoreData(_ data: Data, completionHandler: @escaping @Sendable ((any Error)?) -> Void) -> Self {
        self.restoreData(data, completionHandler: completionHandler)
        return self
    }
}
