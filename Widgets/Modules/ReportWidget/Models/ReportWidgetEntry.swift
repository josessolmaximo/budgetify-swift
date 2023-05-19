//
//  ReportWidgetEntry.swift
//  WidgetsExtension
//
//  Created by Joses Solmaximo on 26/04/23.
//

import WidgetKit
import OrderedCollections

struct ReportWidgetEntry: TimelineEntry {
    let date: Date
    let configuration: ReportConfigurationIntent
    var budgets: [Budget] = []
    var transactions: [Transaction] = []
    var categories: [Category] = []
    var shortcuts: [Shortcut] = []
    
    var sortedTransactions: OrderedDictionary<Date, [Transaction]> = [:]
    var categoryData: OrderedDictionary<String, Decimal> = [:]
    var chartData: [Double] = []
    var dates: [Date] = []
    var totalAmount: Decimal = 0
}
