//
//  EditContent.swift
//  Photo Stitch
//
//  Created by Azuby on 7/14/25.
//

import UIKit
import SwiftUI

class EditContent: UIViewPointSubview {
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
