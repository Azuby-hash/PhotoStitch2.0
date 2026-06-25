//
//  PhotoStitchControl.swift
//  PhotoStitch
//
//  Created by TapUniverse Dev9 on 25/6/26.
//

import AppIntents
import SwiftUI
import WidgetKit

struct PhotoStitchControl: ControlWidget {
    static let kind: String = "com.azubylabs.photostitch.intents"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: Self.kind) {
            ControlWidgetButton(action: StitchPhotosIntent()) {
                Label("Stitch Photos", image: "rectangle.grid.1x2.fill.2.badge.sparkles")
            }
        }
        .displayName("Stitch Photos")
        .description("Quickly auto-stitch recent screenshot photos.")
    }
}
