//
//  BudgetWidgetProvider.swift
//  WidgetsExtension
//
//  Created by Joses Solmaximo on 21/04/23.
//

import WidgetKit

struct BudgetWidgetProvider: IntentTimelineProvider {
    private let mockBudgets: [Budget] = [
        Budget(),
        Budget(),
        Budget(),
    ]
    
    func placeholder(in context: Context) -> BudgetWidgetEntry {
        return BudgetWidgetEntry(date: Date(), configuration: BudgetConfigurationIntent(), budgets: mockBudgets)
    }

    func getSnapshot(for configuration: BudgetConfigurationIntent, in context: Context, completion: @escaping (BudgetWidgetEntry) -> ()) {
        var entry = BudgetWidgetEntry(date: Date(), configuration: configuration)
        
        let budgets = WidgetDataManager.getBudgets()
        let transactions = WidgetDataManager.getTransactions()
        let categories = WidgetDataManager.getCategories()
        let shortcuts = WidgetDataManager.getShortcuts()
        
        entry.budgets = budgets
        entry.transactions = transactions
        entry.categories = categories
        entry.shortcuts = shortcuts
        
        completion(entry)
    }

    func getTimeline(for configuration: BudgetConfigurationIntent, in context: Context, completion: @escaping (Timeline<BudgetWidgetEntry>) -> ()) {
        var entry = BudgetWidgetEntry(date: Date(), configuration: configuration)
        
        let budgets = WidgetDataManager.getBudgets()
        let transactions = WidgetDataManager.getTransactions()
        let categories = WidgetDataManager.getCategories()
        let shortcuts = WidgetDataManager.getShortcuts()
        
        entry.budgets = budgets
        entry.transactions = transactions
        entry.categories = categories
        entry.shortcuts = shortcuts
        
        let timeline = Timeline(entries: [entry], policy: .after(.now.advanced(by: 60 * 60 * 30)))
        
        completion(timeline)
    }
}
