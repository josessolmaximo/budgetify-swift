//
//  LimitedReportWidgetProvider.swift
//  WidgetsExtension
//
//  Created by Joses Solmaximo on 26/04/23.
//

import WidgetKit

struct LimitedReportWidgetProvider: IntentTimelineProvider {
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
    
    func placeholder(in context: Context) -> LimitedReportWidgetEntry {
        let categories = MockCategoryService().categories.values.reduce([], +)
        
        return LimitedReportWidgetEntry(date: Date(), configuration: LimitedReportConfigurationIntent(), transactions: mockTransactions, categories: categories)
    }
    
    func getSnapshot(for configuration: LimitedReportConfigurationIntent, in context: Context, completion: @escaping (LimitedReportWidgetEntry) -> ()) {
        let entry = configureEntry(config: configuration)
        
        let configuredEntry = configureChart(entry: entry)
        
        completion(configuredEntry)
    }

    func getTimeline(for configuration: LimitedReportConfigurationIntent, in context: Context, completion: @escaping (Timeline<LimitedReportWidgetEntry>) -> ()) {
        let entry = configureEntry(config: configuration)
        
        let configuredEntry = configureChart(entry: entry)
        
        let timeline = Timeline(entries: [configuredEntry], policy: .after(.now.advanced(by: 60 * 60 * 30)))
        
        completion(timeline)
    }
    
    func configureEntry(config: LimitedReportConfigurationIntent) -> LimitedReportWidgetEntry {
        var entry = LimitedReportWidgetEntry(date: Date(), configuration: config)
        
        let transactions = WidgetDataManager.getTransactions()
        let categories = WidgetDataManager.getCategories()
        
        entry.transactions = transactions
        entry.categories = categories
        
        return entry
    }
    
    func configureChart(entry: LimitedReportWidgetEntry) -> LimitedReportWidgetEntry {
        var entry = entry
        
        var startDate = Date().startOfWeek.startOfDay
        
        var weekTransactions: [Transaction] {
            entry.transactions.filter { transaction in
                (Date().startOfWeek.startOfDay...Date().endOfWeek.endOfDay).contains(transaction.date) && transaction.type == entry.configuration.transactionType.value
            }
        }
        
        entry.chartData = [Double](repeating: 0.0, count: 7)
        
        while startDate <= Date().endOfWeek.startOfDay {
            entry.dates.append(startDate)
            startDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        }

        for day in entry.dates {
            entry.sortedTransactions[day] = weekTransactions.filter({ $0.date.startOfDay == day })
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
        
        entry.totalAmount = weekTransactions.reduce(0, { result, transaction in
            result + (transaction.amount ?? 0)
        })
        
        
        return entry
    }
}

extension ReportWidgetType {
    var toString: String {
        switch self {
        case .unknown:
            return ""
        case .expense:
            return "Expense"
        case .income:
            return "Income"
        }
    }
    var value: TransactionType {
        switch self {
        case .unknown:
            return .expense
        case .expense:
            return .expense
        case .income:
            return .income
        }
    }
}
