//
//  BudgetSheetViewModel.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 28/11/22.
//

import SwiftUI
import OrderedCollections

protocol BudgetSheetProtocol {
    var budgets: [Budget] { get }
    
    var budgetService: BudgetServiceProtocol { get }
    
    func getBudgets() async
}

@MainActor
class BudgetSheetViewModel: ObservableObject {
    
    @Published var isErrorAlertShown = false
    @Published var isCategorySheetShown = false
    @Published var isDeleteAlertShown = false
    
    @Published var isCarryoverPopoverShown = false
    
    @Published var errorAlertMessage: String?
    @Published var shouldSheetDismiss = false
    
    @Published var loading = false
    
    @Published var budget: Budget
    
    public let parentVM: BudgetSheetProtocol
    
    public var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter
    }
    
    private let uneditedBudget: Budget
    
    private let validator = BudgetValidator()
    private let transactionService: TransactionServiceProtocol
    
    init(budget: Budget, parentVM: BudgetSheetProtocol, transactionService: TransactionServiceProtocol){
        self.budget = budget
        self.uneditedBudget = budget
        self.parentVM = parentVM
        self.transactionService = transactionService
    }
    
    func createBudget() async {
        loading = true
        
        ErrorManager.shared.logRequest(vm: self)
        
        do {
            try BudgetValidator.validate(budget: budget)
            
            var nextPeriod = budget
            
            if budget.endDate < Date() {
                while !(nextPeriod.startDate...nextPeriod.endDate).contains(Date()){
                    nextPeriod = nextPeriod.nextPeriod
                }
            }
            
            try await parentVM.budgetService.createBudget(budget: nextPeriod)
            
            let transactions = try await transactionService.getTransactions(startDate: nextPeriod.startDate, endDate: nextPeriod.endDate)
            
            let newTransactions = transactions.filter { transaction in
                nextPeriod.categories.contains(transaction.category) &&
                nextPeriod.range.contains(transaction.date) &&
                !transaction.budgetRefs.contains(nextPeriod.id.uuidString)
            }
            
            for var transaction in newTransactions {
                if transaction.type == .expense {
                    try await parentVM.budgetService.updateBudgetAmount(id: nextPeriod.id.uuidString, amount: transaction.amount?.doubleValue ?? 0)
                    
                    transaction.budgetRefs.append(nextPeriod.id.uuidString)
                    
                    try await transactionService.updateTransaction(transaction: transaction)
                }
            }
            
            await parentVM.getBudgets()
            
            shouldSheetDismiss = true
            
            AnalyticService.incrementUserProperty(.budgets, value: 1)
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
        
        loading = false
    }
    
    func updateBudget() async {
        loading = true
        
        ErrorManager.shared.logRequest(vm: self)
        
        do {
            try BudgetValidator.validate(budget: budget)
            try await parentVM.budgetService.updateBudget(budget: budget)
            
            if budget.range != uneditedBudget.range || budget.categories != uneditedBudget.categories {
                let prevTransactions = try await transactionService.getTransactions(startDate: uneditedBudget.startDate, endDate: uneditedBudget.endDate)
                let transactions = try await transactionService.getTransactions(startDate: budget.startDate, endDate: budget.endDate)
                
                let newTransactions = transactions.filter { transaction in
                    budget.categories.contains(transaction.category) &&
                    budget.range.contains(transaction.date) &&
                    !transaction.budgetRefs.contains(budget.id.uuidString)
                }
                
                let oldTransactions = prevTransactions.filter { transaction in
                    uneditedBudget.categories.contains(transaction.category) &&
                    uneditedBudget.range.contains(transaction.date) &&
                    transaction.budgetRefs.contains(uneditedBudget.id.uuidString) &&
                    (
                        !budget.categories.contains(transaction.category) ||
                        !budget.range.contains(transaction.date)
                    )
                }
                
                for var transaction in newTransactions {
                    if transaction.type == .expense {
                        try await parentVM.budgetService.updateBudgetAmount(id: budget.id.uuidString, amount: transaction.amount?.doubleValue ?? 0)
                        
                        transaction.budgetRefs.append(budget.id.uuidString)
                        
                        try await transactionService.updateTransaction(transaction: transaction)
                    }
                }
                
                for var transaction in oldTransactions {
                    if transaction.type == .expense {
                        try await parentVM.budgetService.updateBudgetAmount(id: budget.id.uuidString, amount: -(transaction.amount?.doubleValue ?? 0))
                        
                        transaction.budgetRefs.removeAll(where: { $0 == budget.id.uuidString })
                        
                        try await transactionService.updateTransaction(transaction: transaction)
                    }
                }
            }
            
            await parentVM.getBudgets()
            
            shouldSheetDismiss = true
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
        
        loading = false
    }
    
    func deleteBudget() async {
        loading = true
        
        ErrorManager.shared.logRequest(vm: self)
        
        do {
            try await parentVM.budgetService.deleteBudget(budget: budget)
            await parentVM.getBudgets()
            
            shouldSheetDismiss = true
            
            AnalyticService.incrementUserProperty(.budgets, value: -1)
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
        
        loading = false
    }
    
    func configureEndDate(){
        switch budget.period.type {
        case .daily:
            if let newDate = Calendar.current.date(byAdding: .day, value: budget.period.amount - 1, to: budget.startDate.startOfDay){
                budget.endDate = newDate.endOfDay
            }
        case .weekly:
            let startDayNextSecond = Calendar.current.date(byAdding: .second, value: 1, to: budget.startDate)!
            if let newDate = Calendar.current.date(byAdding: .day, value: budget.period.amount * 7, to: startDayNextSecond){
                let startDayPrevSecond = Calendar.current.date(byAdding: .second, value: -1, to: newDate.startOfDay)!
                budget.endDate = startDayPrevSecond
            }
        case .monthly:
            switch budget.period.customType {
            case .first:
                if let nextDate = Calendar.current.date(bySetting: .day, value: budget.period.amount, of: budget.startDate){
                    budget.endDate = nextDate.endOfDay
                }
            case .last:
                let range = Calendar.current.range(of: .day, in: .month, for: budget.startDate)?.count ?? 31
                
                if let nextDate = Calendar.current.date(bySetting: .day, value: range - budget.period.amount + 1, of: budget.startDate){
                    let nextRange = Calendar.current.range(of: .day, in: .month, for: nextDate)?.count ?? 31
                    
                    if range != nextRange {
                        let nextRangeDate = Calendar.current.date(bySetting: .day, value: nextRange - budget.period.amount + 1, of: nextDate)!
                        
                        budget.endDate = nextRangeDate.endOfDay
                    } else {
                        budget.endDate = nextDate.endOfDay
                    }
                }
            }
        case .custom:
            break
        }
    }
}

