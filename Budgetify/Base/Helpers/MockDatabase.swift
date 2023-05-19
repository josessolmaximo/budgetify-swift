//
//  MockDatabase.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 08/02/23.
//

import Foundation

class MockDatabase {
    var transactions: [Transaction] = []
    var categories: [Category] = initialCategories.values.reduce([], +)
    var wallets: [Wallet] = defaultWallets
    var budgets: [Budget] = setupBudgets()
    
    static func setupBudgets() -> [Budget] {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        
        var editedBudgets: [Budget] = []
        
        for var budget in defaultBudgets {
            budget.startDate = yesterday.startOfDay
            budget.endDate = yesterday.endOfDay
            editedBudgets.append(budget.nextPeriod)
        }
        
        return editedBudgets
    }
}
