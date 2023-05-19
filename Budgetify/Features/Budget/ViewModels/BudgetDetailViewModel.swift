//
//  BudgetDetailViewModel.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 01/12/22.
//

import Foundation
import OrderedCollections

@MainActor
class BudgetDetailViewModel: ObservableObject {
    @Published var isBudgetSheetShown = false
    
    @Published var budget: Budget
    @Published var selectedTransaction: Transaction?
    
    @Published var transactions: OrderedDictionary<Date, [Transaction]> = [:]
    
    @Published var selectedBudget = -1
    
    @Published var loading = false
    
    let parentVM: BudgetSheetProtocol
    
    init(budget: Budget, parentVM: BudgetSheetProtocol) {
        self.budget = budget
        self.parentVM = parentVM
    }
    
    func configureTransactions(transactions: [Transaction]){
        var filteredDict: OrderedDictionary<Date, [Transaction]> = [:]
        
        for transaction in transactions {
            if transaction.budgetRefs.contains(budget.id.uuidString) {
                filteredDict[transaction.date.removedTime, default: []].append(transaction)
            }
        }
        
        self.transactions = filteredDict
    }
}
