//
//  EditSort.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 6/14/26.
//

import UIKit
import SwiftUI
import PhotosUI

extension EditOverlay {
    func setupSort() {
        guard let editUpdater = editUpdater, let context = context else { return }
        
        let sortControl = EditSortControl()
        addSubview(sortControl)
        sortControl.addConstraintFitBoundsTo(self)
        sortControl.setup(editUpdater: editUpdater, context: context)
    }

    func updateSort() {
        guard let editUpdater = editUpdater, let context = context else { return }
        
        if let view = subviews.first(type: EditSortControl.self) {
            view.update(editUpdater: editUpdater, context: context)
        }
    }
}

extension EditContent {
    func setupSort() {
        
    }
    
    func updateSort() {

    }
}
