//
//  EditStitch.swift
//  Photo Stitch
//
//  Created by Azuby on 6/24/25.
//

import UIKit
import SwiftUI

extension EditOverlay {
    func setupStitch() {
        guard let editUpdater = editUpdater, let context = context else { return }
        
        let stitchControl = EditStitchControl()
        addSubview(stitchControl)
        stitchControl.addConstraintFitBoundsTo(self)
        stitchControl.setup(editUpdater: editUpdater, context: context)
    }

    func updateStitch() {
        guard let editUpdater = editUpdater, let context = context else { return }
        
        subviews.first(type: EditStitchControl.self)?.update(editUpdater: editUpdater, context: context)
        
        if let view = subviews.first(type: EditStitchControl.self) {
            context.coordinator.scrollView?.passViews.append(view)
        }
    }
}

extension EditContent {
    func setupStitch() {
        
    }
    
    func updateStitch() {

    }
}

@Observable class EditStitchModel {
    @ObservationIgnored var context: EditGallery.Context?
    
    private(set) var selectItem: StitchItem?
    private(set) var constraints: [NSLayoutConstraint] = []
    private(set) var frames: [(item: StitchItem, rect: CGRect)] = []
    private(set) var translateBefore: CGPoint = .zero
    private(set) var translateAfter: CGPoint = .zero
    
    func setTranslateBefore(_ translate: CGPoint) {
        translateBefore = translate
    }
    
    func setTranslateAfter(_ translate: CGPoint) {
        translateAfter = translate
    }
    
    func setSelectItem(_ item: StitchItem?) {
        context?.coordinator.content?.editUpdater.items.forEach { item in
            if item.process.rect.height < MIN_REMOVE || item.process.rect.width < MIN_REMOVE {
                context?.coordinator.content?.editUpdater.items = context?.coordinator.content?.editUpdater.items.filter({ $0 != item }) ?? []
            }
        }
        
        selectItem = item
        
        if item == nil {
            removeStitchConstraints()
            
            frames = []
            translateBefore = .zero
            translateAfter = .zero
        } else {
            frames = context?.coordinator.content?.editUpdater.items.map({ ($0, $0.process.rect) }) ?? []
            translateBefore = .zero
            translateAfter = .zero
        }
    }
    
    func setConstraints(_ constraints: [NSLayoutConstraint]) {
        let currConstraints = self.constraints
        constraints.forEach({ NSLayoutConstraint.activate([$0]) })
        removeStitchConstraints(currConstraints)
        self.constraints = constraints
    }
    
    private func removeStitchConstraints(_ constraints: [NSLayoutConstraint]? = nil) {
        let constraints = constraints ?? self.constraints
        constraints.forEach({ $0.isActive = false })
        self.constraints.removeAll(where: { constraints.contains($0) })
    }
}
