//
//  MockBudgetService.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 08/02/23.
//

import Foundation

class MockBudgetService: BudgetServiceProtocol {
    let db: MockDatabase
    
    init(db: MockDatabase = MockDatabase()) {
        self.db = db
    }
    
    func updateBudget(budget: Budget) async throws {
        if let index = db.budgets.firstIndex(where: { $0 == budget}){
            db.budgets[index] = budget
        }
    }
    
    func createBudget(budget: Budget) async throws {
        db.budgets.append(budget)
    }
    
    func deleteBudget(budget: Budget) async throws {
        if let index = db.budgets.firstIndex(where: { $0 == budget}){
            db.budgets.remove(at: index)
        }
    }
    
    func getBudgets() async throws -> [Budget] {
        return db.budgets
    }
    
    func updateBudgetAmount(id: String, amount: Double) async throws {
        if let index = db.budgets.firstIndex(where: { $0.id.uuidString == id}){
            db.budgets[index].spentAmount += Decimal(amount)
        }
    }
    
    func updateBudgetHistory(id: String, history: [BudgetHistory]) async throws {
        if let index = db.budgets.firstIndex(where: { $0.id.uuidString == id}){
            db.budgets[index].history = history
        }
    }
}
