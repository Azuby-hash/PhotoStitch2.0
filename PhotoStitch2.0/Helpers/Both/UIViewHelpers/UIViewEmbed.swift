//
//  UIViewFromView.swift
//  Sticker Maker
//
//  Created by TapUniverse Dev9 on 9/1/26.
//

import SwiftUI
import UIKit

fileprivate let EMBED_SCALE: CGFloat = 1.5

/**
 Create class A like this then u can use this in storyboard or xib
 ```
 struct B: ViewEmbedProtocol {
     var body: some View {
         <Make your content>
     }
 }
 
 class A: ViewEmbed<B> {
    <Do your setup>
 }
 ```
 
 - Important: Remember to use **dismiss()** if u remove this view but not its parent UIViewController
 */
func viewEmbed<Content: View>(@ViewBuilder content: () -> Content) -> UIView {
    let view = ViewEmbedView<Content>()

    let hosting = UIHostingController(rootView: ViewEmbedContent(content: content()))
    view.addSubview(hosting.view)
    hosting.view.backgroundColor = .clear
    
    view.hosting = hosting
    
    return view
}

fileprivate class ViewEmbedView<Content: View>: UIView {
    var hosting: UIHostingController<ViewEmbedContent<Content>>? // DO NOT ADD WEAK
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let targetFrame = CGRect(mid: bounds.mid, size: bounds.size * EMBED_SCALE)
        
        if hosting?.view.bounds.size == .zero || CATransaction.animationDuration() > 0 {
            hosting?.view.frame = targetFrame
        } else {
            hosting?.view.frame = targetFrame
        }
    }
}

fileprivate struct ViewEmbedContent<Content: View>: View {
    let content: Content
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                content.frame(width: geometry.size.width / EMBED_SCALE, height: geometry.size.height / EMBED_SCALE)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
