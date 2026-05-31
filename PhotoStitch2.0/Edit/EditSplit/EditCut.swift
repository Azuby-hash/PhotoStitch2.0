//
//  EditCut.swift
//  PhotoCut2.0
//
//  Created by Azuby on 5/30/26.
//

import UIKit
import SwiftUI

extension EditOverlay {
    func setupCut() {
        guard let editUpdater = editUpdater, let context = context else { return }
        
        let cutControl = EditCutControl()
        addSubview(cutControl)
        cutControl.addConstraintFitBoundsTo(self)
        cutControl.setup(editUpdater: editUpdater, context: context)
    }

    func updateCut() {
        guard let editUpdater = editUpdater, let context = context else { return }
        
        if let view = subviews.first(type: EditCutControl.self) {
            view.update(editUpdater: editUpdater, context: context)
            context.coordinator.scrollView?.passViews.append(view)
        }
    }
}

extension EditContent {
    func setupCut() {
        
    }
    
    func updateCut() {

    }
}
