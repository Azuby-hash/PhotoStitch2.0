//
//  EditVC.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 5/7/26.
//

import SwiftUI
import Combine

private let contentCoordinate = "51ab628f2a62a3b3"

struct Edit: View {
    @State var editUpdater: EditUpdater
    
    @State var childFrames: [String: CGRect] = [:]
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                let safeAreaInsets = IOS26 ? geometry.safeAreaInsets : EdgeInsets()
                let bonusInset = getInset(geometry)
                let totalInset = EdgeInsets(top: safeAreaInsets.top + bonusInset.top, leading: safeAreaInsets.leading + bonusInset.leading, bottom: safeAreaInsets.bottom + bonusInset.bottom, trailing: safeAreaInsets.trailing + bonusInset.trailing)
                
                EditContent(edgeInsets: totalInset) {
                    if editUpdater.axis == .vertical {
                        VStack(spacing: 0) {
                            ForEach(editUpdater.items, id: \.id) { item in
                                EditChild(item: item, clean: editUpdater.clean, axis: editUpdater.axis)
                                    .onGeometryChange(for: CGRect.self) { childGeo in
                                        return childGeo.frame(in: .named(contentCoordinate))
                                    } action: { newValue in
                                        childFrames[item.id] = newValue
                                    }
                                    .onDisappear {
                                        childFrames[item.id] = nil
                                    }
                            }
                        }
                        .frame(width: geometry.size.width - totalInset.leading - totalInset.trailing)
                    } else {
                        HStack(spacing: 0) {
                            ForEach(editUpdater.items, id: \.id) { item in
                                EditChild(item: item, clean: editUpdater.clean, axis: editUpdater.axis)
                                    .onGeometryChange(for: CGRect.self) { childGeo in
                                        return childGeo.frame(in: .named(contentCoordinate))
                                    } action: { newValue in
                                        childFrames[item.id] = newValue
                                    }
                                    .onDisappear {
                                        childFrames[item.id] = nil
                                    }
                            }
                        }
                        .frame(width: geometry.size.height - totalInset.bottom - totalInset.top)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            GeometryReader { geometry in
                ForEach(childFrames.map({ $0 }), id: \.key) { (id, frame) in
                    Rectangle()
                        .stroke(lineWidth: 10)
                        .fill(Color.red)
                        .frame(width: frame.width, height: frame.height)
                        .offset(.zero + frame.origin)
                        .ignoresSafeArea()
                }
            }
        }
        .coordinateSpace(.named(contentCoordinate))
        .background(Color._background)
        .environment(editUpdater)
    }
    
    func getInset(_ geometry: GeometryProxy) -> EdgeInsets {
        var hozInset = editUpdater.axis == .vertical ? geometry.size.width * 0.2 : 48
        var topInset = editUpdater.axis == .horizontal ? geometry.size.height * 0.1 : 48
        var bottomInset = editUpdater.axis == .horizontal ? geometry.size.height * 0.2 : 48
        
        if isIpad {
            hozInset = editUpdater.axis == .vertical ? geometry.size.width * 0.3 : 48
            topInset = editUpdater.axis == .horizontal ? geometry.size.height * 0.2 : 48
            bottomInset = editUpdater.axis == .horizontal ? geometry.size.height * 0.3 : 48
        }
        
        let edgeInsets = EdgeInsets(top: topInset, leading: hozInset, bottom: bottomInset, trailing: hozInset)
        
        return edgeInsets
    }
}

struct EditChild: View {
    let item: StitchItem
    let clean: Bool
    let axis: Edge.Set
    
    var body: some View {
        let viewFrame = item.process.rect * item.size
        
        GeometryReader { geometry in
            let viewSize = item.size.aspectFill(to: geometry.size)
            let viewOffset = item.process.rect.origin * viewSize
            
            if let image = UIImage(data: clean ? item.clean : item.image) {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: viewSize.width, height: viewSize.height)
                    .offset(x: -viewOffset.x, y: -viewOffset.y)
            }
        }
        .aspectRatio(viewFrame.width / viewFrame.height, contentMode: .fit)
        .frame(maxWidth: axis == .vertical ? .infinity : nil, maxHeight: axis == .horizontal ? .infinity : nil)
        .clipped()
    }
}

@Observable class EditUpdater {
    var items: [StitchItem]
    var axis: Edge.Set
    var clean: Bool = false
    
    init(items: [StitchItem], axis: Edge.Set) {
        self.items = items
        self.axis = axis
    }
}
