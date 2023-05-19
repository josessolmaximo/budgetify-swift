//
//  IntentHandler.swift
//  WidgetIntentsExtension
//
//  Created by Joses Solmaximo on 25/04/23.
//

import Intents

class IntentHandler: INExtension, BudgetConfigurationIntentHandling {
    private var budgets: [DisplayBudget] = WidgetDataManager.getBudgets().map { budget in
        return DisplayBudget(identifier: budget.id.uuidString, display: budget.name)
    }
    
    func defaultBudget(for intent: BudgetConfigurationIntent) -> DisplayBudget? {
        return budgets.first
    }
    
    func resolveShowsAddButton(for intent: BudgetConfigurationIntent, with completion: @escaping (INBooleanResolutionResult) -> Void) {
        completion(.success(with: true))
    }
    
    func resolveShowsShortcuts(for intent: BudgetConfigurationIntent, with completion: @escaping (INBooleanResolutionResult) -> Void) {
        completion(.success(with: false))
    }
    
    func resolveBudget(for intent: BudgetConfigurationIntent, with completion: @escaping (DisplayBudgetResolutionResult) -> Void) {
        if let firstBudget = budgets.first {
            completion(.success(with: firstBudget))
        }
    }
    
    func provideBudgetOptionsCollection(for intent: BudgetConfigurationIntent, with completion: @escaping (INObjectCollection<DisplayBudget>?, Error?) -> Void) {
        let collection = INObjectCollection(items: budgets)
        
        completion(collection, nil)
    }
}
