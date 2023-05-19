//
//  BudgetService.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 28/11/22.
//

import SwiftUI
import FirebaseFirestore

protocol BudgetServiceProtocol {
    func getBudgets() async throws -> [Budget]
    func updateBudget(budget: Budget) async throws
    func updateBudgetAmount(id: String, amount: Double) async throws
    func updateBudgetHistory(id: String, history: [BudgetHistory]) async throws
    func createBudget(budget: Budget) async throws
    func deleteBudget(budget: Budget) async throws
}

class BudgetService: BudgetServiceProtocol {
    @AppStorage("selectedUserId", store: .grouped) var userId: String = ""
    
    var dbRef: CollectionReference {
        return Firestore.firestore().collection("users").document(userId).collection("budgets")
    }
    
//    init(userId: String) {
//        self.dbRef = Firestore.firestore().collection("users").document(userId).collection("budgets")
//    }
    
    func getBudgets() async throws -> [Budget] {
        do {
            let snapshot = try await dbRef.getDocuments()
            
            var budgets: [Budget] = []
            
            snapshot.documents.forEach { document in
                let data = document.data()
                
                guard var decodedData = Budget(dict: data) else {
                    return
                }
                
                decodedData.history.sort {
                    $0.startDate > $1.startDate
                }
                
                budgets.append(decodedData)
            }
            
            budgets.sort {
                $0.order < $1.order
            }
            
            return budgets
        } catch {
            throw error.firestoreError
        }
    }
    
    func updateBudget(budget: Budget) async throws {
        do {
            try await dbRef.document(budget.id.uuidString).setData(budget.dictionary)
        } catch {
            throw error.firestoreError
        }
    }
    
    func updateBudgetAmount(id: String, amount: Double) async throws {
        do {
            try await dbRef.document(id).updateData(["spentAmount": FieldValue.increment(amount)])
        } catch {
            throw error.firestoreError
        }
    }
    
    func updateBudgetHistory(id: String, history: [BudgetHistory]) async throws {
        do {
            try await dbRef.document(id).updateData(["history": history.map({$0.dictionary})])
        } catch {
            throw error.firestoreError
        }
    }
    
    func createBudget(budget: Budget) async throws {
        do {
            try await dbRef.document(budget.id.uuidString).setData(budget.dictionary)
        } catch {
            throw error.firestoreError
        }
    }
    
    func deleteBudget(budget: Budget) async throws {
        do {
            try await dbRef.document(budget.id.uuidString).delete()
        } catch {
            throw error.firestoreError
        }
    }
}
