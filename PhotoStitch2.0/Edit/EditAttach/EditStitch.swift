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
    
    var selectItem: StitchItem?
}
