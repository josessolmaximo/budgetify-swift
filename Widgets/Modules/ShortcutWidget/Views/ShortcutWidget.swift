//
//  ShortcutWidget.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 28/04/23.
//

import SwiftUI
import WidgetKit

struct ShortcutWidget: Widget {
    let kind: String = "ShortcutWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ShortcutConfigurationIntent.self, provider: ShortcutWidgetProvider()) { entry in
           ShortcutWidgetView(entry: entry)
        }
        .configurationDisplayName("Shortcuts")
        .description("Access your shortcuts and add transactions from widgets")
        .supportedFamilies([.systemMedium])
    }
}

struct ShortcutWidgetView: View {
    @Environment(\.widgetFamily) var widgetFamily
    
    @StateObject var tm = ThemeManager()
    
    var entry: ShortcutWidgetEntry
    
    var body: some View {
        ZStack {
            switch widgetFamily {
            case .systemMedium:
                SmallShortcutWidget(entry: entry)
            default:
                Color.clear
            }
        }
        .environmentObject(tm)
    }
}
