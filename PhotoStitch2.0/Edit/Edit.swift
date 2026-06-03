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
                let totalInset = EdgeInsets(top: safeAreaInsets.top + bonusInset.top, leading: safeAreaInsets.leading + bonusInset.leading, bottom: safeAreaInsets.bottom + bonusInset.bottom, trailing: safeAreaInsets.trailing + bonusInset.trailing)
                
                EditGallery(geometry: geometry, edgeInsets: totalInset, baseInsets: bonusInset)
//                    .ignoresSafeArea()
//                    .modifier(EdgeModifier(top: 44, bottom: 60))
            }
            
            EditTop()
            EditBottom()
        }
        .environment(editUpdater)
        .animation(.smooth(duration: ANIM_DURATION), value: editUpdater.tab)
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
    case stitch = "stitch"
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
    
    var stitchUpdater: EditStitchUpdater? = .init() // DO NOT SET NIL HERE OR INSIDE WILL NOT UPDATE
    var cutUpdater: EditCutUpdater? = .init() // DO NOT SET NIL HERE OR INSIDE WILL NOT UPDATE
    
    let editGallery = EditGalleryModel()
    
    init(items: [StitchItem], axis: NSLayoutConstraint.Axis) {
        self.items = items
        self.axis = axis
        
        self.stitchUpdater = nil
        self.cutUpdater = nil
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
