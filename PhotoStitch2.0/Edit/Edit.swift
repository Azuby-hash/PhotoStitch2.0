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
    
    @State var childFrames: [String: CGRect] = [:]
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                let safeAreaInsets = IOS26 ? geometry.safeAreaInsets : EdgeInsets()
                let bonusInset = getInset(geometry)
                let totalInset = EdgeInsets(top: safeAreaInsets.top + bonusInset.top, leading: safeAreaInsets.leading + bonusInset.leading, bottom: safeAreaInsets.bottom + bonusInset.bottom, trailing: safeAreaInsets.trailing + bonusInset.trailing)
                
                EditGallery(geometry: geometry, edgeInsets: totalInset)
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

enum EditTab: String, CaseIterable {
    case stitch = "stitch", control = "stitch.control"
    case split = "split"
    case sort = "sort"
    case none = "none"
}

@Observable class EditUpdater {
    var items: [StitchItem]
    var axis: NSLayoutConstraint.Axis
    var clean: Bool = false
    var tab = EditTab.none
    var anim = false
    
    let editGallery = EditGalleryModel()
    
    init(items: [StitchItem], axis: NSLayoutConstraint.Axis) {
        self.items = items
        self.axis = axis
    }
    
    func animIfNeeded(perform: @escaping () -> Void) {
        if anim {
            perform()
        } else {
            UIView.performWithoutAnimation {
                perform()
            }
        }
    }
}
