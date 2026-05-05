//
//  ViewHelpers.swift
//  PillCounter
//
//  Created by TapUniverse Dev9 on 16/12/25.
//

import SwiftUI

var isPreview: Bool {
    get { ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" }
}

extension View {
    @ViewBuilder
    func center(axis: Axis) -> some View {
        if axis == .horizontal {
            HStack { Spacer(); self; Spacer() }
        } else {
            VStack { Spacer(); self; Spacer() }
        }
    }
    
    @ViewBuilder
    func align(edge: Edge, constant: CGFloat) -> some View {
        if edge == .top {
            VStack { self.padding(.top, constant); Spacer() }
        } else if edge == .bottom {
            VStack { Spacer(); self.padding(.bottom, constant) }
        } else if edge == .leading {
            HStack { self.padding(.leading, constant); Spacer() }
        } else {
            HStack { Spacer(); self.padding(.trailing, constant) }
        }
    }
    
    /**
     Read size of superview
     */
    @ViewBuilder
    func geometry<Content: View>(@ViewBuilder setup: @escaping (GeometryProxy, Self) -> Content) -> some View {
        GeometryReader { geometry in
            setup(geometry, self)
        }
    }
    
    func onChange<V: Equatable>(_ value: V, perform action: @escaping (V) -> ()) -> some View {
        if #available(iOS 17.0, *) {
            return self.onChange(of: value) { oldValue, newValue in
                action(newValue)
            }
        } else {
            return self.onChange(of: value) { newValue in
                action(newValue)
            }
        }
    }
    
    func toAny() -> AnyView {
        AnyView(self)
    }
    
    func toolBarAppear(_ visibility: Visibility, for bar: ToolbarPlacement) -> some View {
        if #available(iOS 18.0, *) {
            return self.toolbarVisibility(visibility, for: bar)
        } else {
            return self.toolbar(visibility, for: bar)
        }
    }
    
    func toolBarBackgroundAppear(_ visibility: Visibility, for bar: ToolbarPlacement) -> some View {
        if #available(iOS 18.0, *) {
            return self.toolbarBackgroundVisibility(visibility, for: bar)
        } else {
            return self.toolbarBackground(visibility, for: bar)
        }
    }
}

extension ToolbarItem {
    func hiddenBackground() -> some ToolbarContent {
        if #available(iOS 26, *) {
            return self.sharedBackgroundVisibility(.hidden)
        } else {
            return self
        }
    }
}

extension ToolbarItemGroup {
    func hiddenBackground() -> some ToolbarContent {
        if #available(iOS 26, *) {
            return self.sharedBackgroundVisibility(.hidden)
        } else {
            return self
        }
    }
}

extension GeometryProxy {
    var safeAreaSize: CGSize {
        get { CGSize(width: size.width - safeAreaInsets.leading - safeAreaInsets.trailing, height: size.height - safeAreaInsets.bottom - safeAreaInsets.top) }
    }
}

struct GeometryKey: EnvironmentKey {
    static let defaultValue: CGRect = CGRect(x: 0, y: 0, width: 10, height: 10)
}

// 2. Extend EnvironmentValues
extension EnvironmentValues {
    var frameInGlobal: CGRect {
        get { self[GeometryKey.self] }
        set { self[GeometryKey.self] = newValue }
    }
}

struct FramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

// 1. The Modifier that does the heavy lifting
struct GeometryEnvironmentModifier: ViewModifier {
    @State private var frame: CGRect = CGRect(x: 0, y: 0, width: 10, height: 10)

    func body(content: Content) -> some View {
        content
            // Inject the current frame into the environment for all children
            .environment(\.frameInGlobal, frame)
            // Measure the view
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: FramePreferenceKey.self, value: geometry.frame(in: .global))
                }
            )
            // Update the state when the measurement changes
            .onPreferenceChange(FramePreferenceKey.self) { newFrame in
                self.frame = newFrame
            }
    }
}

// 2. The Clean Extension
extension View {
    func autoGeometry() -> some View {
        self.modifier(GeometryEnvironmentModifier())
    }
}
