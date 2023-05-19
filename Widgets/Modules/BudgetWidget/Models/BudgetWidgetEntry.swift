//
//  BudgetWidgetEntry.swift
//  WidgetsExtension
//
//  Created by Joses Solmaximo on 21/04/23.
//

import WidgetKit

struct BudgetWidgetEntry: TimelineEntry {
    let date: Date
    let configuration: BudgetConfigurationIntent
    var budgets: [Budget] = []
    var transactions: [Transaction] = []
    var categories: [Category] = []
    var shortcuts: [Shortcut] = []
}
