//
//  MainGlass.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 4/27/26.
//

import SwiftUI

struct MainGlass<S: Shape>: ViewModifier {
    enum Mode {
        case color(Color)
        case clear
    }
    
    let shape: S
    let type: Mode
    var interactive = true
    
    func body(content: Content) -> some View {
        switch(type) {
        case .clear:
            content.modifier(GlassModifier(shape: shape)
                .setBaseBackground(.ultraThinMaterial)
                .setGlassBackground(Color(uiColor: .systemBackground).opacity(0.01))
                .setInteractive(interactive))
        case .color(let color):
            content.modifier(GlassModifier(shape: shape)
                .setBaseBackground(color)
                .setGlassBackground(color)
                .setInteractive(interactive))
        }
    }
}
