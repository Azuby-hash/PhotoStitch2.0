//
//  EditItem.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 5/8/26.
//

import SwiftUI

@Observable class EditItem {
    var image: UIImage
    var process: StitchProcess
    
    init(image: UIImage, process: StitchProcess) throws {
        guard let ciImage = CIImage(image: image) else {
            throw MainError.error("Cant convert to ciimage")
        }
        
        self.image = image
        self.process = process.setup(image: ciImage, config: Stitch.getConfig(mode: .image))
    }
}
