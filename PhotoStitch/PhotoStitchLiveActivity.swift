//
//  PhotoStitchLiveActivity.swift
//  PhotoStitch
//
//  Created by TapUniverse Dev9 on 25/6/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct PhotoStitchAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct PhotoStitchLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PhotoStitchAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension PhotoStitchAttributes {
    fileprivate static var preview: PhotoStitchAttributes {
        PhotoStitchAttributes(name: "World")
    }
}

extension PhotoStitchAttributes.ContentState {
    fileprivate static var smiley: PhotoStitchAttributes.ContentState {
        PhotoStitchAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: PhotoStitchAttributes.ContentState {
         PhotoStitchAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: PhotoStitchAttributes.preview) {
   PhotoStitchLiveActivity()
} contentStates: {
    PhotoStitchAttributes.ContentState.smiley
    PhotoStitchAttributes.ContentState.starEyes
}
