//
//  EditVC.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 5/7/26.
//

import SwiftUI

struct Edit: View {
    @Binding var updater: EditUpdater
    
    var body: some View {
        
    }
}

@Observable class EditUpdater {
    var items: [EditItem]
    
    init(images: [UIImage]) throws {
        items = try images.map({ image in
            try EditItem(image: image, process: StitchProcess())
        })
    }
}
