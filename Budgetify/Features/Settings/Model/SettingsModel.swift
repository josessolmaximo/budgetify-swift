//
//  SettingsModel.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 01/05/23.
//

import Foundation

struct TransactionCSV: Codable {
    var date: Date
    var amount: Decimal
    var type: String
    var category: String
    var originWallet: String
    var destinationWallet: String
    var note: String
    var location: String
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case date
        case amount
        case type
        case category
        case originWallet
        case destinationWallet
        case note
        case location
    }
}
