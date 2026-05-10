//
//  GlassModifier.swift
//  StitchPhotos2.0
//
//  Created by TapUniverse Dev9 on 22/1/26.
//

import SwiftUI

enum GlassType {
    case regular
    case clear
    case identity
}

struct GlassModifier<S: Shape>: ViewModifier {
    private var shape: S
    private var interactive: Bool = true
    private var tint: Color?
    private var glassType: GlassType = .regular
    private var glassBackground: AnyShapeStyle? = AnyShapeStyle(Color.clear)
    private var baseBackground: AnyShapeStyle = AnyShapeStyle(Color(uiColor: .systemBackground))
    private var baseHasShadow: Bool = true
    
    init(shape: S) {
        self.shape = shape
    }
    
    func body(content: Content) -> AnyView {
        if #available(iOS 26.0, *) {
            var glass: Glass
            
            switch glassType {
            case .clear:
                glass = Glass.clear
            case .regular:
                glass = Glass.regular
            case .identity:
                glass = Glass.identity
            }
            
            if interactive {
                glass = glass.interactive(true)
            }
            
            if let tint = tint {
                glass = glass.tint(tint)
            }
            
            if let glassBackground = glassBackground {
                return content.background(glassBackground).clipShape(shape).glassEffect(glass, in: shape).toAny()
            } else {
                return content.clipShape(shape).toAny()
            }
        } else {
            if baseHasShadow {
                return content.background(baseBackground).clipShape(shape).shadow(color: Color(.sRGBLinear, white: 0.5, opacity: 0.15), radius: 10).toAny()
            } else {
                return content.background(baseBackground).clipShape(shape).toAny()
            }
        }
    }
    
    func setGlassType(_ type: GlassType) -> Self {
        var modifier = self
        modifier.glassType = type
        return modifier
    }
    
    func setInteractive(_ interactive: Bool) -> Self {
        var modifier = self
        modifier.interactive = interactive
        return modifier
    }
    
    func setTint(_ tint: Color?) -> Self {
        var modifier = self
        modifier.tint = tint
        return modifier
    }
    
    func setGlassBackground<Shape: ShapeStyle>(_ style: Shape) -> Self {
        var modifier = self
        if let _ = style as? GlassEmpty {
            modifier.glassBackground = nil
        } else {
            modifier.glassBackground = AnyShapeStyle(style)
        }
        return modifier
    }
    
    func setBaseBackground<Shape: ShapeStyle>(_ style: Shape) -> Self {
        var modifier = self
        modifier.baseBackground = AnyShapeStyle(style)
        return modifier
    }
    
    func setBaseHasShadow(_ hasShadow: Bool) -> Self {
        var modifier = self
        modifier.baseHasShadow = hasShadow
        return modifier
    }
}

struct GlassEmpty: ShapeStyle { }

struct GlassContainer<Content: View>: View {
    @ViewBuilder var content: () -> Content
    var body: some View {
        if #available(iOS 26, *) {
            GlassEffectContainer(content: content)
        } else {
            content()
        }
    }
}
