//
//  AnalyticModel.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 30/04/23.
//

import Foundation

struct UserProperties: Codable {
    var transactions: Int
    var wallets: Int
    var budgets: Int
    var subcategories: Int
    var favicons: Int
    var shortcuts: Int
    var sharing: [String]
    var widgets: [String]
    var paywallConfig: [String: Int]
    var requestedRating: Bool
    var lastSeen: Date
    var shownOnboarding: Bool
    var skippedOnboarding: Bool
    var appVersion: String
    var faviconURLs: [String]
    
    enum CodingKeys: CodingKey {
        case transactions
        case wallets
        case budgets
        case subcategories
        case favicons
        case shortcuts
        case sharing
        case widgets
        case paywallConfig
        case requestedRating
        case lastSeen
        case shownOnboarding
        case skippedOnboarding
        case appVersion
        case faviconURLs
    }
}
