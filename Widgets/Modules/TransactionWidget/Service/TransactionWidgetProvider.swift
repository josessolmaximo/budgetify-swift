//
//  TransactionWidgetProvider.swift
//  WidgetsExtension
//
//  Created by Joses Solmaximo on 21/04/23.
//

import WidgetKit

struct TransactionWidgetProvider: IntentTimelineProvider {
    private let mockTransactions: [Transaction] = [
        Transaction(category: "", amount: 100, originWallet: "", destinationWallet: ""),
        Transaction(category: "", amount: 100, originWallet: "", destinationWallet: ""),
        Transaction(category: "", amount: 100, originWallet: "", destinationWallet: ""),
        Transaction(category: "", amount: 100, originWallet: "", destinationWallet: ""),
        Transaction(category: "", amount: 100, originWallet: "", destinationWallet: ""),
        Transaction(category: "", amount: 100, originWallet: "", destinationWallet: ""),
        Transaction(category: "", amount: 100, originWallet: "", destinationWallet: ""),
        Transaction(category: "", amount: 100, originWallet: "", destinationWallet: ""),
        Transaction(category: "", amount: 100, originWallet: "", destinationWallet: ""),
        Transaction(category: "", amount: 100, originWallet: "", destinationWallet: ""),
    ]
    
    func placeholder(in context: Context) -> TransactionWidgetEntry {
        let categories = MockCategoryService().categories.values.reduce([], +)
        
        return TransactionWidgetEntry(date: Date(), configuration: ConfigurationIntent(), transactions: mockTransactions, categories: categories)
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (TransactionWidgetEntry) -> ()) {
        var entry = TransactionWidgetEntry(date: Date(), configuration: configuration)
        
        let transactions = WidgetDataManager.getTransactions()
        let categories = WidgetDataManager.getCategories()
        let shortcuts = WidgetDataManager.getShortcuts()
        
        entry.transactions = transactions.filter({
            (configuration.period.startDate...configuration.period.endDate).contains($0.date)
        })
        
        entry.categories = categories
        entry.shortcuts = shortcuts
        
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<TransactionWidgetEntry>) -> ()) {
        var entry = TransactionWidgetEntry(date: Date(), configuration: configuration)
        
        let transactions = WidgetDataManager.getTransactions()
        let categories = WidgetDataManager.getCategories()
        let shortcuts = WidgetDataManager.getShortcuts()
        
        entry.transactions = transactions.filter({
            (configuration.period.startDate...configuration.period.endDate).contains($0.date)
        })
        
        entry.categories = categories
        entry.shortcuts = shortcuts
        
        let timeline = Timeline(entries: [entry], policy: .after(.now.advanced(by: 60 * 60 * 30)))
        
        completion(timeline)
    }
}
