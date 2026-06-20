//
//  SegmentView.swift
//  StitchPhotos2.0
//
//  Created by TapUniverse Dev9 on 26/3/26.
//

import SwiftUI
import UIKit
import Combine

struct SegmentViewItem<ID: Equatable & Hashable> {
    let id: ID
    let text: String
}

struct SegmentView<ID: Equatable & Hashable>: View {
    @Binding var selected: ID
    
    let items: [SegmentViewItem<ID>]
    var selectedColor = Color(uiColor: .label)
     
    @State private var translate: CGFloat = .zero
    
    var body: some View {
        GeometryReader { geometry in
            let spacing = CGFloat(-8)
            let itemSize = CGSize(width: (geometry.size.width - 8 + spacing) / CGFloat(items.count) - spacing, height: geometry.size.height - 8)
            let index = items.firstIndex(where: { $0.id == selected }) ?? 0
            let leading = min(CGFloat(items.count - 1) * (itemSize.width + spacing), max(0, CGFloat(index) * (itemSize.width + spacing) + translate))
            
            if #available(iOS 26.0, *) {
                Picker("", selection: $selected) {
                    ForEach(items, id: \.text) { item in
                        Text(item.text).tag(item.id)
                    }
                }
                .pickerStyle(.segmented)
                .controlSize(.large)
                .onAppear {
                    UISegmentedControl.appearance().setTitleTextAttributes([
                        .font: UIFont.systemFont(ofSize: 16, weight: .semibold)
                    ], for: .normal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ZStack {
                    // Base layer: Unselected items
                    HStack(spacing: spacing) {
                        ForEach(items, id: \.text) { item in
                            VStack {
                                Text(item.text)
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                            .foregroundStyle(Color(uiColor: .label).opacity(0.6)) // Slightly dimmed when unselected
                            .frame(width: itemSize.width, height: itemSize.height)
                            .onTapGesture {
                                selected = item.id
                            }
                        }
                    }
                    
                    // DestinationOut Hole Puncher
                    HStack {
                        Capsule().frame(width: itemSize.width, height: itemSize.height)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .offset(x: leading)
                    .animation(.smooth(duration: 0.25), value: leading)
                    .blendMode(.destinationOut)
                    
                    // Selection Capsule Background Tint
                    HStack {
                        Capsule()
                            .fill(Color(uiColor: .systemBackground))
                            .frame(width: itemSize.width, height: itemSize.height)
                            .opacity(0.07)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .offset(x: leading)
                    .animation(.smooth(duration: 0.25), value: leading)
                    .gesture(DragGesture()
                        .onChanged({ value in
                            translate = value.translation.width
                        })
                        .onEnded({ value in
                            let index = min(items.count - 1, max(0, Int(floor((leading + itemSize.width / 2) / itemSize.width))))
                            
                            if items.indices.contains(index) {
                                selected = items[index].id
                            }
                            
                            translate = .zero
                        }))
                    
                    // Top layer: Selected items (revealed only via mask)
                    HStack(spacing: spacing) {
                        ForEach(items, id: \.text) { item in
                            VStack {
                                Text(item.text)
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                            .foregroundStyle(selectedColor)
                            .frame(width: itemSize.width, height: itemSize.height)
                        }
                    }
                    .mask {
                        HStack {
                            Capsule().frame(width: itemSize.width, height: itemSize.height)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .offset(x: leading)
                        .animation(.smooth(duration: 0.25), value: leading)
                    }
                    .allowsHitTesting(false)
                }
                .compositingGroup()
                .padding(4)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.clear.background(.ultraThinMaterial).clipShape(.capsule))
            }
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    ZStack {
        Color.gray.opacity(0.2).ignoresSafeArea() // Added background to preview ultraThinMaterial
        SegmentView(selected: .constant(0), items: [
            .init(id: 0, text: "Photos"),
            .init(id: 1, text: "Video"),
        ])
    }
}
