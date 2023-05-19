//
//  ReportWidget.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 25/04/23.
//

import SwiftUI
import WidgetKit

struct ReportWidget: Widget {
    let kind: String = "ReportWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ReportConfigurationIntent.self, provider: ReportWidgetProvider()) { entry in
           ReportWidgetView(entry: entry)
        }
        .configurationDisplayName("Reports")
        .description("View your reports and analyze your expenses")
        .supportedFamilies([.systemMedium])
    }
}

struct ReportWidgetView: View {
    @Environment(\.widgetFamily) var widgetFamily
    
    @StateObject var tm = ThemeManager()
    
    var entry: ReportWidgetEntry
    
    var body: some View {
        ZStack {
            switch widgetFamily {
            case .systemMedium:
                MediumReportWidget(entry: entry)
            default:
                Color.clear
            }
        }
        .environmentObject(tm)
    }
}
