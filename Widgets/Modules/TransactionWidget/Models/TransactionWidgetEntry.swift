//
//  TransactionWidgetEntry.swift
//  WidgetsExtension
//
//  Created by Joses Solmaximo on 21/04/23.
//

import WidgetKit

struct TransactionWidgetEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    var transactions: [Transaction] = []
    var categories: [Category] = []
    var shortcuts: [Shortcut] = []
}

extension Period {
    var toString: String {
        switch self {
        case .unknown:
            return ""
        case .thisMonth:
            return "This Month"
        case .thisWeek:
            return "This Week"
        case .today:
            return "Today"
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
        case .today:
            return Date().startOfDay
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
        case .today:
            return Date().endOfDay
        }
    }
}
