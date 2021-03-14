//
//  CentralisWidget.swift
//  CentralisWidgetExtension
//
//  Created by Andromeda on 14/03/2021.
//

import SwiftUI
import WidgetKit

@main
struct CentralisWidgets: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        LongTimetableWidget()
        NextLessonWidget()
    }
}
