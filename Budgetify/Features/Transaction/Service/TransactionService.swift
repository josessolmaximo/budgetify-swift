//
//  TransactionService.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 02/12/22.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

protocol TransactionServiceProtocol {
    func getTransactions(startDate: Date, endDate: Date) async throws -> [Transaction]
    func updateTransaction(transaction: Transaction) async throws
    func deleteTransaction(transaction: Transaction) async throws
    func createTransaction(transaction: Transaction) async throws
}

protocol TransactionSheetProtocol {
    var transactions: [Transaction] { get set }
}

class TransactionService: TransactionServiceProtocol {
    @AppStorage("selectedUserId", store: .grouped) var userId: String = ""
    
    var dbRef: CollectionReference {
        return Firestore.firestore().collection("users").document(userId).collection("transactions")
    }
    
    var walletRef: CollectionReference {
        return Firestore.firestore().collection("users").document(userId).collection("wallets")
    }
    
    var budgetRef: CollectionReference {
        return Firestore.firestore().collection("users").document(userId).collection("budgets")
    }
    
    let storageRef = Storage.storage().reference()
    
    func getTransactions(startDate: Date, endDate: Date) async throws -> [Transaction] {
        do {
            let snapshot = try await dbRef
                .whereField("date", isGreaterThanOrEqualTo: startDate)
                .whereField("date", isLessThanOrEqualTo: endDate)
                .order(by: "date", descending: true)
                .getDocuments()
            
            var transactions: [Transaction] = []
            
            snapshot.documents.forEach { document in
                if let decodedData = Transaction(dict: document.data()){
                    transactions.append(decodedData)
                }
            }
            
            transactions.sort {
                $0.date > $1.date
            }
            
            return transactions
        } catch {
            throw error.firestoreError
        }
    }
    
    func createTransaction(transaction: Transaction) async throws {
        do {
            try await dbRef.document(transaction.id.uuidString).setData(transaction.dictionary)
        } catch {
            throw error.firestoreError
        }
    }
    
    func updateTransaction(transaction: Transaction) async throws {
        do {
            try await dbRef.document(transaction.id.uuidString).setData(transaction.dictionary)
        } catch {
            throw error.firestoreError
        }
    }
    
    func deleteTransaction(transaction: Transaction) async throws {
        do {
            try await dbRef.document(transaction.id.uuidString).delete()
        } catch {
            throw error.firestoreError
        }
    }
}

