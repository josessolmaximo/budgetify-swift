//
//  SettingsManager.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 19/03/23.
//

import SwiftUI

class SettingsManager: ObservableObject {
    @AppStorage("amountsVisible", store: .grouped) var amountsVisibleAS: Bool = true
    @AppStorage("recurringBadge", store: .grouped) var recurringBadgeAS: Bool = true
    @AppStorage("currencySymbols", store: .grouped) var currencySymbolsAS: Bool = true
    @AppStorage("lineGraphStyle", store: .grouped) var lineGraphStyleAS: String = LineGraphStyle.straight.rawValue
    @AppStorage("decimalPoints", store: .grouped) var decimalPointsAS: Int = 2
    @AppStorage("hideEmptyWallets", store: .grouped) var hideEmptyWalletsAS: Bool = false
    @AppStorage("showReportSubcategories", store: .grouped) var showReportSubcategoriesAS: Bool = true
    @AppStorage("startOfWeek", store: .grouped) var startOfWeekAS: Int = Weekday.sunday.rawValue

    @Published var amountsVisible = true
    @Published var recurringBadge = true
    @Published var currencySymbols = true
    @Published var hideEmptyWallets = false
    @Published var showReportSubcategories = true
    
    @Published var lineGraphStyle: LineGraphStyle = .straight
    @Published var startOfWeek: Weekday = .sunday
    
    @Published var decimalPoints = 2
    
    static let shared = SettingsManager()
    
    init(){
        readStorage()
    }
    
    func readStorage(){
        amountsVisible = amountsVisibleAS
        recurringBadge = recurringBadgeAS
        currencySymbols = currencySymbolsAS
        hideEmptyWallets = hideEmptyWalletsAS
        showReportSubcategories = showReportSubcategoriesAS
        
        lineGraphStyle = LineGraphStyle(rawValue: lineGraphStyleAS) ?? .straight
        startOfWeek = Weekday(rawValue: startOfWeekAS) ?? .sunday
        
        decimalPoints = decimalPointsAS
    }
    
    func setStorage(){
        amountsVisibleAS = amountsVisible
        recurringBadgeAS = recurringBadge
        currencySymbolsAS = currencySymbols
        hideEmptyWalletsAS = hideEmptyWallets
        showReportSubcategoriesAS = showReportSubcategories
        
        lineGraphStyleAS = lineGraphStyle.rawValue
        startOfWeekAS = startOfWeek.rawValue
        
        decimalPointsAS = decimalPoints
    }
}

protocol HasDisplayString {
    var displayString: String { get }
}

enum LineGraphStyle: String, CaseIterable, HasDisplayString {
    case straight = "Straight"
    case curved = "Curved"
    
    var displayString: String {
        switch self {
        case .straight:
            return "Straight"
        case .curved:
            return "Curved"
        }
    }
}

enum Weekday: Int, CaseIterable, HasDisplayString {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
    var displayString: String {
        switch self {
        case .sunday:
            return "Sunday"
        case .monday:
            return "Monday"
        case .tuesday:
            return "Tuesday"
        case .wednesday:
            return "Wednesday"
        case .thursday:
            return "Thursday"
        case .friday:
            return "Friday"
        case .saturday:
            return "Saturday"
        }
    }
}
