//
//  EditVC.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 5/7/26.
//

import SwiftUI
import Combine

struct Edit: View {
    @State var editUpdater: EditUpdater
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                let safeAreaInsets = IOS26 ? geometry.safeAreaInsets : EdgeInsets()
                let bonusInset = getInset(geometry)
                
                EditContent(edgeInsets: EdgeInsets(top: safeAreaInsets.top + bonusInset.top, leading: safeAreaInsets.leading + bonusInset.leading, bottom: safeAreaInsets.bottom + bonusInset.bottom, trailing: safeAreaInsets.trailing + bonusInset.trailing)) {
                    LazyVStack {
                        ForEach(editUpdater.items, id: \.image) { item in
                            EditImage(image: getData(item), size: item.size, rect: item.process.rect)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
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

struct EditImage: View {
    let image: Data
    let size: CGSize
    let rect: CGRect
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            GeometryReader { geometry in
                let viewSize = size.aspectFill(to: geometry.size)
                let viewFrame = rect * size
                
                if let image = try? image.getThumbnail(originSize: size) {
                    Image(uiImage: image)
                        .frame(width: viewSize.width, height: viewSize.height)
                        .offset(x: -viewFrame.minX, y: -viewFrame.minY)
                }
            }
        }
        .aspectRatio(rect.width / rect.height, contentMode: .fit)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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

extension Edit {
    func getData(_ item: StitchItem) -> Data {
        return editUpdater.clean ? item.clean : item.image
    }
}

