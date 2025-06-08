//
//  GlucosaWidgetLiveActivity.swift
//  GlucosaWidget
//
//  Created by Rocco López on 07/06/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct GlucosaWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct GlucosaWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: GlucosaWidgetAttributes.self) { context in
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

extension GlucosaWidgetAttributes {
    fileprivate static var preview: GlucosaWidgetAttributes {
        GlucosaWidgetAttributes(name: "World")
    }
}

extension GlucosaWidgetAttributes.ContentState {
    fileprivate static var smiley: GlucosaWidgetAttributes.ContentState {
        GlucosaWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: GlucosaWidgetAttributes.ContentState {
         GlucosaWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: GlucosaWidgetAttributes.preview) {
   GlucosaWidgetLiveActivity()
} contentStates: {
    GlucosaWidgetAttributes.ContentState.smiley
    GlucosaWidgetAttributes.ContentState.starEyes
}
