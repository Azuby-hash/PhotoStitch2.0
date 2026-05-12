//
//  EditContent.swift
//  StitchPhotos2.0
//
//  Created by TapUniverse Dev9 on 5/2/26.
//

import UIKit
import SwiftUI

struct EditContent<Content: View>: UIViewRepresentable {
    @Environment(EditUpdater.self) var updater

    let edgeInsets: EdgeInsets
    let content: () -> Content
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let scrollView = UIScrollViewPointOut()
            .edelegate(context.coordinator)
            .emaximumZoomScale(MAX_ZOOM)
            .ebackgroundColor(.clear)
            .eclipsToBounds(false)
            .eshowsVerticalScrollIndicator(false)
            .eshowsHorizontalScrollIndicator(false)
        let hosting = UIHostingController(rootView: content())
        
        view.eaddSubview(scrollView
            .eaddSubview(hosting.view, [.leading(0), .trailing(0), .top(0), .bottom(0)]), [.leading(edgeInsets.leading), .trailing(edgeInsets.trailing), .top(edgeInsets.top), .bottom(edgeInsets.bottom)])
        
        context.coordinator.view = view
        context.coordinator.scrollView = scrollView
        context.coordinator.hosting = hosting
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.hosting?.rootView = content()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        weak var view: UIView?
        weak var scrollView: UIScrollView?
        weak var hosting: UIHostingController<Content>?
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hosting?.view
        }
    }
}
