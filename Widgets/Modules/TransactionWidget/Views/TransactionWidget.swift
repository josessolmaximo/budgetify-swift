//
//  TransactionWidget.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 21/04/23.
//

import SwiftUI
import WidgetKit

struct TransactionWidget: Widget {
    let kind: String = "TransactionWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: TransactionWidgetProvider()) { entry in
           TransactionWidgetView(entry: entry)
        }
        .configurationDisplayName("Transactions")
        .description("View your transactions and their amounts")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct TransactionWidgetView: View {
    @Environment(\.widgetFamily) var widgetFamily
    
    @StateObject var tm = ThemeManager()
    
    var entry: TransactionWidgetEntry
    
    var body: some View {
        ZStack {
            switch widgetFamily {
            case .systemSmall:
                SmallTransactionWidget(entry: entry)
            case .systemMedium:
                MediumTransactionWidget(entry: entry)
            default:
                Color.clear
            }
        }
        .environmentObject(tm)
    }
}

struct TransactionWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        let mockDatabase = MockDatabase()
        
        let placeholder = TransactionWidgetEntry(date: Date(), configuration: ConfigurationIntent(), transactions: Array(MockTransactionService(db: mockDatabase).transactions.prefix(3)), categories: mockDatabase.categories)
        
        TransactionWidgetView(entry: placeholder)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .environmentObject(ThemeManager())
        
        TransactionWidgetView(entry: placeholder)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .environmentObject(ThemeManager())
    }
}
