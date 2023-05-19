//
//  RecurringService.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 02/12/22.
//

import SwiftUI
import FirebaseFirestore

protocol RecurringServiceProtocol {
    func addRecurringTransaction(transactions: [Transaction]) async throws
    func updateRecurringTransaction(transaction: Transaction) async throws
    func deleteRecurringTransaction(transaction: Transaction) async throws
    func getRecurringTransactions() async throws -> [Transaction]
}

class RecurringService: RecurringServiceProtocol {
    @AppStorage("selectedUserId", store: .grouped) var userId: String = ""
    
    var dbRef: CollectionReference {
        return Firestore.firestore().collection("users").document(userId).collection("recurring")
    }
    
//    init(userId: String) {
//        self.dbRef = Firestore.firestore().collection("users").document(userId).collection("recurring")
//    }
    
    func addRecurringTransaction(transactions: [Transaction]) async throws {
        for transaction in transactions {
            do {
                try await dbRef.document(transaction.id.uuidString).setData(transaction.nextRecurringPeriod.dictionary)
            } catch {
                throw error.firestoreError
            }
        }
    }
    
    func updateRecurringTransaction(transaction: Transaction) async throws {
        var mutableTransaction = transaction
        
        mutableTransaction.recurring.date = mutableTransaction.recurring.lastOccured
        
        do {
            try await dbRef.document(mutableTransaction.id.uuidString).setData(mutableTransaction.nextRecurringPeriod.dictionary)
        } catch {
            throw error.firestoreError
        }
    }
    
    func deleteRecurringTransaction(transaction: Transaction) async throws {
        do {
            try await dbRef.document(transaction.id.uuidString).delete()
        } catch {
            throw error.firestoreError
        }
    }
    
    func getRecurringTransactions() async throws -> [Transaction] {
        do {
            let snapshot = try await dbRef.getDocuments()
            
            var transactions: [Transaction] = []
            
            snapshot.documents.forEach { document in
                guard let decodedData = Transaction(dict: document.data()) else {
                    return
                }
                
                transactions.append(decodedData)
            }
            
            return transactions
        } catch {
            throw error.firestoreError
        }
    }
}

class MockRecurringService: RecurringServiceProtocol {
    public var transactions: [Transaction] = []
    
    func getRecurringTransactions() async throws -> [Transaction] {
        return transactions
    }
    
    func addRecurringTransaction(transactions: [Transaction]) async throws {
        
    }
    
    func updateRecurringTransaction(transaction: Transaction) async throws {
        
    }
    
    func deleteRecurringTransaction(transaction: Transaction) async throws {
        
    }
}
