//
//  MenuPopover.swift
//  RemoveObject3.0
//
//  Created by TapUniverse Dev9 on 10/6/26.
//

import UIKit
import SwiftUI

fileprivate let MENU_ID = "fc7f0176616fa4c0"
fileprivate let MENU_SPACE = "a1c7df036f346c9e"

struct MenuPopoverItem: Identifiable {
    let id = UUID()
    var icon: Image?
    var name: String
    var close: Bool = true
    var action: () -> Void
}

struct MenuPopover<Content: View>: View {
    typealias Item = MenuPopoverItem

    @Binding var showMenu: Bool
    var items: [Item]
    @ViewBuilder let content: () -> Content
    
    @State var maxHeight = CGFloat.infinity
    @State private var hoveredName: String?
    @State private var itemFrames = [String: CGRect]()
    
    @State var hoverID = UUID().uuidString
    
    @Namespace var namespace
    
    var body: some View {
        ZStack {
            MenuContainer {
                if showMenu {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            ForEach(items) { item in
                                HStack {
                                    item.icon
                                    Text(LocalizedStringKey(item.name)); Spacer()
                                }
                                .padding(.horizontal, 12)
                                .frame(height: 44)
                                .scaleEffect(hoveredName == item.name ? 1.03 : 1.0)
                                .animation(.smooth(duration: ANIM_DURATION), value: hoveredName)
                                .frame(maxWidth: .infinity)
                                .onGeometryChange(for: CGRect.self, of: { geometry in
                                    geometry.frame(in: .named(MENU_SPACE))
                                }, action: { newValue in
                                    itemFrames[item.name] = newValue
                                })
                            }
                        }
                        .background(
                            ZStack(alignment: .topLeading) {
                                Color.clear
                                
                                if let hoveredName = hoveredName, let itemFrame = itemFrames[hoveredName] {
                                    Capsule()
                                        .fill(Color.white.opacity(0.15))
                                        .frame(height: itemFrame.height)
                                        .offset(y: itemFrame.minY - 10)
                                        .id(hoverID)
                                }
                            }
                        )
                        .padding(10)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        .coordinateSpace(name: MENU_SPACE)
                        .onGeometryChange(for: CGFloat.self) { geometry in
                            return geometry.size.height
                        } action: { newValue in
                            maxHeight = newValue
                        }
                    }
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .frame(maxHeight: min(maxHeight, 300))
                    .fixedSize()
                    .modifier(MainGlass(shape: RoundedRectangle(cornerRadius: 32), type: .clear))
                    .matchedGeometryEffect(id: MENU_ID, in: namespace)
                } else {
                    content().matchedGeometryEffect(id: MENU_ID, in: namespace)
                }
            }
        }
        .overlay(content: {
            Color.clear
            Gesture(minimumDuration: 0.2)
                .onChanged { point in
                    if showMenu {
                        hoveredName = itemFrames.first(where: { $0.value.contains(point) })?.key
                    } else {
                        withAnimation(.smooth(duration: ANIM_DURATION)) {
                            showMenu = true
                        }
                        hoveredName = itemFrames.first(where: { $0.key == items.last?.name })?.key
                    }
                }
                .onEnded {
                    if let name = hoveredName, let item = items.first(where: { $0.name == name }), showMenu {
                        item.action()
                        
                        if item.close {
                            withAnimation(.smooth(duration: ANIM_DURATION)) {
                                showMenu = false
                            }
                        }
                    }
                    
                    hoveredName = nil
                }
                .onTapGesture(perform: { point in
                    if let name = itemFrames.first(where: { $0.value.contains(point) })?.key, let item = items.first(where: { $0.name == name }), showMenu {
                        item.action()
                        
                        if item.close {
                            withAnimation(.smooth(duration: ANIM_DURATION)) {
                                showMenu = false
                            }
                        }
                        
                        return
                    }
                    
                    withAnimation(.smooth(duration: ANIM_DURATION)) {
                        showMenu = true
                    }
                })
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        })
        .onChange(itemFrames) { itemFrames in
            print(itemFrames)
        }
        .onChange(hoveredName, perform: { _ in
            if hoveredName == nil {
                hoverID = UUID().uuidString
            }
        })
        .animation(.smooth(duration: ANIM_DURATION), value: hoveredName)
    }
    
    fileprivate struct Gesture: UIViewRepresentable {
        let minimumDuration: Double
        
        private var onChanged: ((CGPoint) -> Void)?
        private var onEnded: (() -> Void)?
        
        init(minimumDuration: Double = 0.5) {
            self.minimumDuration = minimumDuration
        }
        
        // MARK: - Coordinator
        final class Coordinator: NSObject {
            var onChanged: ((CGPoint) -> Void)?
            var onEnded: (() -> Void)?

            // Workaround: the Release SIL optimizer (EarlyPerfInliner) crashes on the
            // synthesized deinit of this class, so opt this function out of optimization.
            @_optimize(none)
            deinit {}

            @objc func handleLongPress(_ recognizer: UIGestureRecognizer) {
                guard let view = recognizer.view else { return }
                
                switch recognizer.state {
                case .began, .changed:
                    let location = recognizer.location(in: view)
                    onChanged?(location)
                case .ended, .cancelled:
                    onEnded?()
                default:
                    break
                }
            }
        }
        
        func makeCoordinator() -> Coordinator {
            return Coordinator()
        }
        
        // MARK: - UIViewRepresentable
        func makeUIView(context: Context) -> UIView {
            let view = UIView()
            view.backgroundColor = .clear
            
            // Create and attach the gesture recognizer
            let longPress = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleLongPress))
            longPress.minimumPressDuration = minimumDuration
            longPress.allowableMovement = .infinity
            view.addGestureRecognizer(longPress)
            
            return view
        }
        
        func updateUIView(_ uiView: UIView, context: Context) {
            // Keep the coordinator's closures fresh on view updates
            context.coordinator.onChanged = onChanged
            context.coordinator.onEnded = onEnded
        }
        
        // MARK: - Modifiers
        func onChanged(_ action: @escaping (CGPoint) -> Void) -> Self {
            var gesture = self
            gesture.onChanged = action
            return gesture
        }
        
        func onEnded(_ action: @escaping () -> Void) -> Self {
            var gesture = self
            gesture.onEnded = action
            return gesture
        }
    }
}

fileprivate struct MenuContainer<Content: View>: View {
    @ViewBuilder var content: () -> Content
    var body: some View {
        if #available(iOS 26, *) {
            GlassEffectContainer(content: content)
        } else {
            content()
        }
    }
}
