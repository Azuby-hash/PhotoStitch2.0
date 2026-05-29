//
//  EditSplit.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 5/29/26.
//

import UIKit
import SwiftUI

extension EditOverlay {
    func setupSplit() {
        guard let editUpdater = editUpdater, let context = context else { return }
        
        editUpdater.editStitch.context = context
        
        let splitControl = EditSplitControl()
        addSubview(splitControl)
        splitControl.addConstraintFitBoundsTo(self)
        splitControl.setup(editUpdater: editUpdater, context: context)
    }

    func updateSplit() {
        guard let editUpdater = editUpdater, let context = context else { return }
        
        editUpdater.editStitch.context = context
        
        if let view = subviews.first(type: EditSplitControl.self) {
            view.update(editUpdater: editUpdater, context: context)
            context.coordinator.scrollView?.passViews.append(view)
        }
    }
}

extension EditContent {
    func setupSplit() {
        
    }
    
    func updateSplit() {

    }
}

@Observable class EditSplitModel {
    @ObservationIgnored var context: EditGallery.Context?
    
    
}

