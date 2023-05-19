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
    @AppStorage("lineGraphStyle", store: .grouped) var lineGraphStyleAS: String = "Straight"
    @AppStorage("decimalPoints", store: .grouped) var decimalPointsAS: Int = 2
    @AppStorage("hideEmptyWallets", store: .grouped) var hideEmptyWalletsAS: Bool = false

    @Published var amountsVisible = true
    @Published var recurringBadge = true
    @Published var currencySymbols = true
    @Published var hideEmptyWallets = false
    
    @Published var lineGraphStyle: LineGraphStyle = .straight
    
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
        
        lineGraphStyle = LineGraphStyle(rawValue: lineGraphStyleAS) ?? .straight
        
        decimalPoints = decimalPointsAS
    }
    
    func setStorage(){
        amountsVisibleAS = amountsVisible
        recurringBadgeAS = recurringBadge
        currencySymbolsAS = currencySymbols
        hideEmptyWalletsAS = hideEmptyWallets
        
        lineGraphStyleAS = lineGraphStyle.rawValue
        
        decimalPointsAS = decimalPoints
    }
}

enum LineGraphStyle: String, CaseIterable {
    case straight = "Straight"
    case curved = "Curved"
}
