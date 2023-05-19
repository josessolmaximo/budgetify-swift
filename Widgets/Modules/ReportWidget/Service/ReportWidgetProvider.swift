//
//  ReportWidgetProvider.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 25/04/23.
//

import WidgetKit

struct ReportWidgetProvider: IntentTimelineProvider {
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
    
    func placeholder(in context: Context) -> ReportWidgetEntry {
        let categories = MockCategoryService().categories.values.reduce([], +)
        
        return ReportWidgetEntry(date: Date(), configuration: ReportConfigurationIntent(), transactions: mockTransactions, categories: categories)
    }
    
    func getSnapshot(for configuration: ReportConfigurationIntent, in context: Context, completion: @escaping (ReportWidgetEntry) -> ()) {
        let entry = configureEntry(config: configuration)
        
        let configuredEntry = configureChart(entry: entry)
        
        completion(configuredEntry)
    }

    func getTimeline(for configuration: ReportConfigurationIntent, in context: Context, completion: @escaping (Timeline<ReportWidgetEntry>) -> ()) {
        let entry = configureEntry(config: configuration)
        
        let configuredEntry = configureChart(entry: entry)
     
        let timeline = Timeline(entries: [configuredEntry], policy: .after(.now.advanced(by: 60 * 60 * 30)))
        
        completion(timeline)
    }
    
    func configureEntry(config: ReportConfigurationIntent) -> ReportWidgetEntry {
        var entry = ReportWidgetEntry(date: Date(), configuration: config)
        
        let transactions = WidgetDataManager.getTransactions()
        let categories = WidgetDataManager.getCategories()
        let shortcuts = WidgetDataManager.getShortcuts()
        
        entry.transactions = transactions
        entry.categories = categories
        entry.shortcuts = shortcuts
        
        return entry
    }
    
    func configureChart(entry: ReportWidgetEntry) -> ReportWidgetEntry {
        var entry = entry
        
        var startDate = entry.configuration.period.startDate
        let endDate = entry.configuration.period.endDate
        
        var selectedTransactions: [Transaction] {
            entry.transactions.filter { transaction in
                (entry.configuration.period.startDate...entry.configuration.period.endDate).contains(transaction.date) && transaction.type == entry.configuration.transactionType.value
            }
        }
        
        while startDate <= endDate {
            entry.dates.append(startDate)
            startDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        }
        
        entry.chartData = [Double](repeating: 0.0, count: entry.dates.count)

        for day in entry.dates {
            entry.sortedTransactions[day] = selectedTransactions.filter({ $0.date.startOfDay == day })
        }

        var maxAmount = entry.sortedTransactions.values.map({ transactions in
            transactions.reduce(0, { $0 + ($1.amount ?? 0) })
        }).max() ?? 1

        if maxAmount == 0 {
            maxAmount = 1
        }
        
        entry.chartData = entry.sortedTransactions.values.map { transactions in
            let amount = transactions.reduce(0, { $0 + ($1.amount ?? 0) }) / maxAmount

            return amount.doubleValue
        }
        
        entry.totalAmount = selectedTransactions.reduce(0, { result, transaction in
            result + (transaction.amount ?? 0)
        })
        
        for transaction in selectedTransactions {
            entry.categoryData[transaction.category, default: 0] += (transaction.amount ?? 0)
        }
        
        entry.categoryData.sort { $0.value > $1.value }
        
        return entry
    }
}

extension ReportWidgetPeriod {
    var toString: String {
        switch self {
        case .unknown:
            return ""
        case .thisMonth:
            return "This Month"
        case .thisWeek:
            return "This Week"
        }
    }
    
    var startDate: Date {
        switch self {
        case .unknown:
            return Date()
        case .thisMonth:
            return Date().startOfMonth().startOfDay
        case .thisWeek:
            return Date().startOfWeek.startOfDay
        }
    }
    
    var endDate: Date {
        switch self {
        case .unknown:
            return Date()
        case .thisMonth:
            return Date().endOfMonth().endOfDay
        case .thisWeek:
            return Date().endOfWeek.endOfDay
        }
    }
}
