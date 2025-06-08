//
//  GlucosaWidgetBundle.swift
//  GlucosaWidget
//
//  Created by Rocco López on 07/06/25.
//

import WidgetKit
import SwiftUI

@main
struct GlucosaWidgetBundle: WidgetBundle {
    var body: some Widget {
        GlucosaWidget()
        GlucosaWidgetControl()
        GlucosaWidgetLiveActivity()
    }
}
