//
//  EditGallery.swift
//  Photo Stitch
//
//  Created by Azuby on 6/22/25.
//

import UIKit
import SwiftUI

class EditOverlay: UIViewPointSubview {
    private(set) weak var editUpdater: EditUpdater?
    private(set) var context: EditGallery.Context?

    func setup(editUpdater: EditUpdater, context: EditGallery.Context) {
        self.editUpdater = editUpdater
        self.context = context
        
        setupStitch()
//        setupSplit()
//        setupSort()
    }
    
    func update(editUpdater: EditUpdater, context: EditGallery.Context) {
        self.editUpdater = editUpdater
        self.context = context
        
        updateStitch()
    }
}
