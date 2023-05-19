//
//  HomeModel.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 02/12/22.
//

import Foundation

let menuItems = [
    "house.fill",
    "creditcard.fill",
    "chart.bar.fill",
    "chart.pie.fill",
    "plus",
]

enum Page: String, CaseIterable {
    case transactions = "house.fill"
    case wallets = "creditcard.fill"
    case budgets = "chart.bar.fill"
    case reports = "chart.pie.fill"
    case transactionSheet = "plus"
}
