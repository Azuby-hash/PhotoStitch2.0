//
//  HomeWeb.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 6/20/26.
//

import UIKit
import SwiftUI
import WebKit

struct HomeWeb: View {
    @Environment(HomeUpdater.self) var homeUpdater
    
    @Binding var showWeb: Bool
    @State private var urlText: String = ""
    @State private var webUpdater = HomeWebUpdater()
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        ZStack {
            if webUpdater.activeURL != nil {
                fullScreenWebView
            } else {
                entryCard
            }
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.smooth(duration: 0.25), value: isSearchFocused)
        .onChange(webUpdater.activeURL) { url in
            if let url = url {
                urlText = url.absoluteString
            }
        }
        .onAppear {
            webUpdater.homeUpdater = homeUpdater
        }
    }
    
    // MARK: - Entry mode (no URL yet)
    
    private var entryCard: some View {
        GlassContainer {
            VStack(spacing: 20) {
                HStack {
                    Text("Enter a Website")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .padding(.leading, 16)
                    
                    Spacer()
                    
                    closeButton(glassType: .color(._background.opacity(0.5)))
                }
                
                searchField(glassType: .color(._background.opacity(0.5)))
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .modifier(MainGlass(shape: RoundedRectangle(cornerRadius: 38), type: .clear))
            
            openWebsiteButton
        }
        .padding(.horizontal, 20)
        .padding(.bottom, isSearchFocused ? 24 : 0)
        .align(edge: .bottom, constant: 0)
    }
    
    // MARK: - Full screen mode (URL active)
    
    private var fullScreenWebView: some View {
        ZStack {
            Color._whiteVert
                .ignoresSafeArea()
            
            HomeWebDetail(requestUrl: $webUpdater.activeURL, controller: webUpdater, topInset: 44 + 24, bottomInset: 60 + 24)
            
            VStack {
                // Top row: back, forward, close — no glass card wrapper, buttons use .clear
                HStack {
                    backForwardButtons(glassType: .clear)
                    Spacer()
                    closeButton(glassType: .clear)
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Bottom row: search field + action icon, both .clear (not inside a GlassContainer)
                HStack(spacing: 12) {
                    searchField(glassType: .clear)
                    bottomActionIconButton
                }
                .padding(.horizontal, 20)
                .padding(.bottom, isSearchFocused ? 24 : 0)
            }
        }
    }
    
    // MARK: - Shared pieces
    
    @ViewBuilder
    private func backForwardButtons(glassType: MainGlass<Capsule>.Mode) -> some View {
        Button {
            webUpdater.goBack()
        } label: {
            Image("chevron.left")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .opacity(webUpdater.canGoBack ? 1 : 0.4)
        }
        .frame(width: 44, height: 44)
        .modifier(MainGlass(shape: .capsule, type: glassType))
        .tint(Color._blackVert)
        .disabled(!webUpdater.canGoBack)
        
        Button {
            webUpdater.goForward()
        } label: {
            Image("chevron.right")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .opacity(webUpdater.canGoForward ? 1 : 0.4)
        }
        .frame(width: 44, height: 44)
        .modifier(MainGlass(shape: .capsule, type: glassType))
        .tint(Color._blackVert)
        .disabled(!webUpdater.canGoForward)
    }
    
    private func closeButton(glassType: MainGlass<Capsule>.Mode) -> some View {
        Button {
            showWeb = false
            isSearchFocused = false
        } label: {
            Image("xmark")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
        }
        .frame(width: 44, height: 44)
        .modifier(MainGlass(shape: .capsule, type: glassType))
        .tint(Color._blackVert)
    }
    
    private func searchField(glassType: MainGlass<Capsule>.Mode) -> some View {
        HStack(spacing: 12) {
            Image("globe")
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
            
            TextField("Search for a website", text: $urlText)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .keyboardType(.webSearch)
                .submitLabel(.go)
                .focused($isSearchFocused)
                .onSubmit {
                    summit()
                }
            
            if !urlText.isEmpty && isSearchFocused {
                Button {
                    urlText = ""
                } label: {
                    Image("xmark.circle.fill")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundStyle(Color._blackVert.opacity(0.5))
                }
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 60)
        .modifier(MainGlass(shape: .capsule, type: glassType))
        .animation(.smooth(duration: ANIM_DURATION), value: urlText.isEmpty)
    }
    
    private var openWebsiteButton: some View {
        Button {
            summit()
        } label: {
            HStack {
                Text("Open Website")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                Image("arrow.forward")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .modifier(MainGlass(shape: .capsule, type: .color(._primary)))
            .tint(.white)
        }
    }
    
    // Icon-only version for full-screen mode, sitting beside the search field
    private var bottomActionIconButton: some View {
        Button {
            if isSearchFocused {
                summit()
            } else {
                webUpdater.snapshot()
            }
        } label: {
            VStack {
                if isSearchFocused {
                    Image("arrow.forward")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                } else {
                    Image("text.viewfinder")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                }
            }
            .frame(width: 60, height: 60)
            .modifier(MainGlass(shape: .capsule, type: .color(._primary)))
            .tint(.white)
            .transition(.opacity)
        }
    }

    private func summit() {
        if let url = URL(string: urlText), !webUpdater.openURL(url), let httpURL = URL(string: "https://www.google.com/search?q=\(urlText)") {
            webUpdater.openURL(httpURL)
            isSearchFocused = false
        }
    }
}

struct HomeWebDetail: UIViewRepresentable {
    @Binding var requestUrl: URL?
    
    let controller: HomeWebUpdater
    let topInset: CGFloat
    let bottomInset: CGFloat
    
    func makeUIView(context: Context) -> WebViewSnapshotView {
        let configuration = WKWebViewConfiguration()
        let webView = WebViewSnapshotView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.clipsToBounds = false
        applyInsets(to: webView)
        
        if let requestUrl = requestUrl {
            webView.load(URLRequest(url: requestUrl))
        }
        
        controller.webView = webView
        return webView
    }
    
    func updateUIView(_ uiView: WebViewSnapshotView, context: Context) {
        applyInsets(to: uiView)
        if uiView.url != requestUrl, let requestUrl = requestUrl {
            uiView.load(URLRequest(url: requestUrl))
        }
    }
    
    private func applyInsets(to webView: WKWebView) {
        let insets = UIEdgeInsets(top: topInset, left: 0, bottom: bottomInset, right: 0)
        webView.scrollView.contentInset = insets
        webView.scrollView.scrollIndicatorInsets = insets
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(controller: controller)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let controller: HomeWebUpdater
        
        init(controller: HomeWebUpdater) {
            self.controller = controller
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            controller.canGoBack = webView.canGoBack
            controller.canGoForward = webView.canGoForward
            controller.activeURL = webView.url
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            controller.canGoBack = webView.canGoBack
            controller.canGoForward = webView.canGoForward
            controller.activeURL = webView.url
            print("HomeWebDetail load failed: \(error.localizedDescription)")
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            controller.canGoBack = webView.canGoBack
            controller.canGoForward = webView.canGoForward
            controller.activeURL = webView.url
            print("HomeWebDetail provisional load failed: \(error.localizedDescription)")
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }

            if navigationAction.navigationType == .linkActivated {
                decisionHandler(.cancel)
                controller.openURL(url)
                return
            }

            decisionHandler(.allow)
        }
    }
}

// MARK: - Web navigation controller, bridges WKWebView state back into SwiftUI
@Observable class HomeWebUpdater {
    var canGoBack: Bool = false
    var canGoForward: Bool = false
    
    fileprivate weak var webView: WebViewSnapshotView?
    fileprivate weak var homeUpdater: HomeUpdater?
    
    var activeURL: URL?
    
    func goBack() {
        webView?.goBack()
    }
    
    func goForward() {
        webView?.goForward()
    }
    
    @discardableResult
    func openURL(_ url: URL) -> Bool {
        if UIApplication.shared.canOpenURL(url) {
            activeURL = url
            webView?.load(URLRequest(url: url))
            return true
        }
        
        return false
    }
    
    func snapshot() {
        guard let webView = webView,
              let homeUpdater = homeUpdater
        else { return }
        
        var currItem: StitchItem?
        
        WebViewSnapshot.shared.capture(webView: webView) { image in
            do {
                let item = try StitchItem(image: image, asset: nil)
                currItem = item

                homeUpdater.items = [item]
                homeUpdater.axis = .vertical
            } catch {
                print(error)
            }
        } doneUI: {
            if currItem != nil {
                homeUpdater.showEdit = true
            }
        }
    }
}
