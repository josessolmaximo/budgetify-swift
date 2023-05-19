//
//  LimitedReportWidgetEntry.swift
//  WidgetsExtension
//
//  Created by Joses Solmaximo on 26/04/23.
//

import WidgetKit
import OrderedCollections

struct LimitedReportWidgetEntry: TimelineEntry {
    let date: Date
    let configuration: LimitedReportConfigurationIntent
    var budgets: [Budget] = []
    var transactions: [Transaction] = []
    var categories: [Category] = []
    
    var sortedTransactions: OrderedDictionary<Date, [Transaction]> = [:]
    var categoryData: OrderedDictionary<String, Decimal> = [:]
    var chartData: [Double] = []
    var dates: [Date] = []
    var totalAmount: Decimal = 0
}
