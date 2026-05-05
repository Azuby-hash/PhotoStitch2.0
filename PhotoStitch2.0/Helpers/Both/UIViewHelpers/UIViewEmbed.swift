//
//  UIViewFromView.swift
//  Sticker Maker
//
//  Created by TapUniverse Dev9 on 9/1/26.
//

import SwiftUI
import UIKit

protocol ViewEmbedProtocol: View {
    static func makeContentController() -> UIHostingController<Self>
}

/**
 Create class A like this then u can use this in storyboard or xib
 ```
 struct B: ViewEmbedProtocol {
     var body: some View {
         <Make your content>
     }
     
     static func makeContentController() -> UIHostingController<B> {
         return UIHostingController(rootView: B())
     }
 }
 
 class A: ViewEmbed<B> {
    <Do your setup>
 }
 ```
 
 - Important: Remember to use **dismiss()** if u remove this view but not its parent UIViewController
 */
class ViewEmbed<Content: ViewEmbedProtocol>: UIView {
    private var didLoad = false
    
    private var contentController: UIHostingController<Content>?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if didLoad { return }
        didLoad = true
        
        contentController = Content.makeContentController()

        if let vc = __findViewController() {
            contentController?.embed(to: self, in: vc)
        }
    }
    
    func dismiss() {
        contentController?.disEmbed()
    }
}

fileprivate extension UIView {
    func __findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.__findViewController()
        } else {
            return nil
        }
    }
}


