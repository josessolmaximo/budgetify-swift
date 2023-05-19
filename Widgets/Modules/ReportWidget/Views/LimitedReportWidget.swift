//
//  LimitedReportWidget.swift
//  WidgetsExtension
//
//  Created by Joses Solmaximo on 26/04/23.
//

import SwiftUI
import WidgetKit

struct LimitedReportWidget: Widget {
    @StateObject var tm = ThemeManager()
    
    let kind: String = "LimitedReportWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: LimitedReportConfigurationIntent.self, provider: LimitedReportWidgetProvider()) { entry in
            SmallReportWidget(entry: entry)
                .environmentObject(tm)
        }
        .configurationDisplayName("Reports")
        .description("View your reports and analyze your expenses")
        .supportedFamilies([.systemSmall])
    }
}
