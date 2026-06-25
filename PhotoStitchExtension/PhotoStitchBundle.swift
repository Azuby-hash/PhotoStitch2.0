//
//  PhotoStitchBundle.swift
//  PhotoStitch
//
//  Created by TapUniverse Dev9 on 25/6/26.
//

import WidgetKit
import SwiftUI

@main
struct PhotoStitchBundle: WidgetBundle {
    var body: some Widget {
        StitchPhotosWidget()
        StitchVideosWidget()
        PhotoStitchControl()
    }
}
