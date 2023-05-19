//
//  BudgetViewModel.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 28/11/22.
//

import SwiftUI
import OrderedCollections
import FirebaseCrashlytics

@MainActor
class BudgetViewModel: ObservableObject, BudgetSheetProtocol {
    @AppStorage("selectedUserId", store: .grouped) var selectedUserId: String = ""
    
    @Published var budgets: [Budget] = []
    
    @Published var isBudgetSheetShown = false
    @Published var isErrorAlertShown = false
    
    @Published var selectedCategories: [Category] = []
    @Published var loading = false
    
    internal let budgetService: BudgetServiceProtocol
    
    init(budgetService: BudgetServiceProtocol) {
        self.budgetService = budgetService
        
        guard !selectedUserId.isEmpty else { return }
        
        Task {
            await getBudgets()
        }
    }
    
    func getBudgets() async {
        loading = true
        
        ErrorManager.shared.logRequest(vm: self)
        
        do {
            let budgets = try await budgetService.getBudgets()
            
            self.budgets = budgets
            
            WidgetDataManager.setBudgets(budgets: budgets)
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
        
        loading = false
    }
    
    func checkDueDates(budgets: [Budget]){
        for budget in budgets {
            if budget.endDate < Date() {
                var nextPeriod = budget.nextPeriod
                
                while !(nextPeriod.startDate...nextPeriod.endDate).contains(Date()){
                    nextPeriod = nextPeriod.nextPeriod
                }
                
                Task {
                    await updateBudget(budget: nextPeriod)
                }
            }
        }
    }
    
    func updateBudget(budget: Budget) async {
        loading = true
        
        ErrorManager.shared.logRequest(vm: self)
        
        do {
            try await budgetService.updateBudget(budget: budget)
            
            await getBudgets()
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
        
        loading  = false
    }
}

