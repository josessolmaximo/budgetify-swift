//
//  BudgetWidget.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 21/04/23.
//

import SwiftUI
import WidgetKit

struct BudgetWidget: Widget {
    let kind: String = "BudgetWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: BudgetConfigurationIntent.self, provider: BudgetWidgetProvider()) { entry in
           BudgetWidgetView(entry: entry)
        }
        .configurationDisplayName("Budgets")
        .description("View your budgets and how much you have spent")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct BudgetWidgetView: View {
    @Environment(\.widgetFamily) var widgetFamily
    
    @StateObject var tm = ThemeManager()
    
    var entry: BudgetWidgetEntry
    
    var body: some View {
        ZStack {
            switch widgetFamily {
            case .systemSmall:
                SmallBudgetWidget(entry: entry)
            case .systemMedium:
                MediumBudgetWidget(entry: entry)
            default:
                Color.clear
            }
        }
        .environmentObject(tm)
    }
}
