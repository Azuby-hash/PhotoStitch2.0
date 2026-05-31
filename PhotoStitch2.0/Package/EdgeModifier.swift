//
//  EdgeModifier.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 5/31/26.
//

import SwiftUI

struct EdgeModifier: ViewModifier {
    let top: CGFloat
    let bottom: CGFloat
    
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .safeAreaBar(edge: .top) {
                    Color.white.opacity(0.00001).frame(height: top)
                }
                .safeAreaBar(edge: .bottom) {
                    Color.white.opacity(0.00001).frame(height: bottom)
                }
        } else {
            content.overlay {
                ZStack {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .frame(maxWidth: .infinity, maxHeight: top + 44)
                        .mask(LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .white, location: 0),
                                .init(color: .white.opacity(0), location: 1)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                        .align(edge: .top, constant: 0)
                        .ignoresSafeArea()
                    
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .frame(maxWidth: .infinity, maxHeight: bottom + 34)
                        .mask(LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .white, location: 0),
                                .init(color: .white.opacity(0), location: 1)
                            ]),
                            startPoint: .bottom,
                            endPoint: .top
                        ))
                        .align(edge: .bottom, constant: 0)
                        .ignoresSafeArea()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            }
        }
    }
}
