//
//  MockTransactionService.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 24/12/22.
//

import Foundation
import OrderedCollections

class MockTransactionService: TransactionServiceProtocol {
    let db: MockDatabase
    let categories = initialCategories.values.reduce([], +)
    let defaultWallet = Wallet(name: "Cash", image: "custom.wallet")
    
    lazy var transactions: [Transaction] = [
        Transaction(category: categories.randomElement()!.id.uuidString, date: Date(), amount: 285743, originWallet: defaultWallets.randomElement()!.id.uuidString, destinationWallet: defaultWallets.randomElement()!.id.uuidString, type: .transfer),
        Transaction(category: categories.randomElement()!.id.uuidString, date: Date(), amount: 515597, originWallet: defaultWallets.randomElement()!.id.uuidString, destinationWallet: defaultWallets.randomElement()!.id.uuidString),
        Transaction(category: categories.randomElement()!.id.uuidString, date: Date(), amount: 790905, originWallet: defaultWallets.randomElement()!.id.uuidString, destinationWallet: defaultWallets.randomElement()!.id.uuidString),
        Transaction(category: categories.randomElement()!.id.uuidString, date: Date(), note: "Meat, eggs, chicken, milk, cheese", amount: 35658, originWallet: defaultWallets.randomElement()!.id.uuidString, destinationWallet: defaultWallets.randomElement()!.id.uuidString),
        Transaction(category: categories.randomElement()!.id.uuidString, date: Date(), note: "Groceries", amount: 641864, originWallet: defaultWallets.randomElement()!.id.uuidString, destinationWallet: defaultWallets.randomElement()!.id.uuidString, recurring: .init(type: .daily, date: Date(), amount: 1, customType: .last)),
        Transaction(category: categories.randomElement()!.id.uuidString, date: Date(), note: "#books #novels", amount: 406262, originWallet: defaultWallets.randomElement()!.id.uuidString, destinationWallet: defaultWallets.randomElement()!.id.uuidString, type: .transfer),
        Transaction(category: categories.randomElement()!.id.uuidString, date: Date(), amount: 206349, originWallet: defaultWallets.randomElement()!.id.uuidString, destinationWallet: defaultWallets.randomElement()!.id.uuidString),
        Transaction(category: categories.randomElement()!.id.uuidString, date: Date(), amount: 11549, originWallet: defaultWallets.randomElement()!.id.uuidString, destinationWallet: defaultWallets.randomElement()!.id.uuidString),
        Transaction(category: categories.randomElement()!.id.uuidString, date: Date(), amount: 901516, originWallet: defaultWallets.randomElement()!.id.uuidString, destinationWallet: defaultWallets.randomElement()!.id.uuidString),
        Transaction(category: categories.randomElement()!.id.uuidString, date: Date(), amount: 718896, originWallet: defaultWallets.randomElement()!.id.uuidString, destinationWallet: defaultWallets.randomElement()!.id.uuidString),
        Transaction(category: categories.randomElement()!.id.uuidString, date: Date(), amount: 711649, originWallet: defaultWallets.randomElement()!.id.uuidString, destinationWallet: defaultWallets.randomElement()!.id.uuidString),
        Transaction(category: categories.randomElement()!.id.uuidString, date: Date(), amount: 676829, originWallet: defaultWallets.randomElement()!.id.uuidString, destinationWallet: defaultWallets.randomElement()!.id.uuidString),
        Transaction(category: categories.randomElement()!.id.uuidString, date: Date(), amount: 35608, originWallet: defaultWallets.randomElement()!.id.uuidString, destinationWallet: defaultWallets.randomElement()!.id.uuidString),
        Transaction(category: categories.randomElement()!.id.uuidString, date: Date(), amount: 523968, originWallet: defaultWallets.randomElement()!.id.uuidString, destinationWallet: defaultWallets.randomElement()!.id.uuidString),
        Transaction(category: categories.randomElement()!.id.uuidString, date: Date(), amount: 823243, originWallet: defaultWallets.randomElement()!.id.uuidString, destinationWallet: defaultWallets.randomElement()!.id.uuidString),
    ]
    
    init(db: MockDatabase = MockDatabase()) {
        self.db = db
        
        let categories = initialCategories.values.reduce([], +)
        
        db.transactions = [
            Transaction(category: categories.randomElement()!.id.uuidString, date: Date(), amount: 285743, originWallet: defaultWallets.randomElement()!.id.uuidString, destinationWallet: defaultWallets.randomElement()!.id.uuidString, type: .transfer),
            Transaction(category: categories.randomElement()!.id.uuidString, date: Date(), amount: 515597, originWallet: defaultWallets.randomElement()!.id.uuidString, destinationWallet: defaultWallets.randomElement()!.id.uuidString),
            Transaction(category: categories.randomElement()!.id.uuidString, date: Date(), amount: 790905, originWallet: defaultWallets.randomElement()!.id.uuidString, destinationWallet: defaultWallets.randomElement()!.id.uuidString),
            Transaction(category: categories.randomElement()!.id.uuidString, date: Date(), note: "Meat, eggs, chicken, milk, cheese", amount: 35658, originWallet: defaultWallets.randomElement()!.id.uuidString, destinationWallet: defaultWallets.randomElement()!.id.uuidString),
            Transaction(category: categories.randomElement()!.id.uuidString, date: Date(), note: "Groceries", amount: 641864, originWallet: defaultWallets.randomElement()!.id.uuidString, destinationWallet: defaultWallets.randomElement()!.id.uuidString, recurring: .init(type: .daily, date: Date(), amount: 1, customType: .last)),
            Transaction(category: categories.randomElement()!.id.uuidString, date: Date(), note: "#books #novels", amount: 406262, originWallet: defaultWallets.randomElement()!.id.uuidString, destinationWallet: defaultWallets.randomElement()!.id.uuidString, type: .transfer),
            Transaction(category: categories.randomElement()!.id.uuidString, date: Date(), amount: 206349, originWallet: defaultWallets.randomElement()!.id.uuidString, destinationWallet: defaultWallets.randomElement()!.id.uuidString),
            Transaction(category: categories.randomElement()!.id.uuidString, date: Date(), amount: 11549, originWallet: defaultWallets.randomElement()!.id.uuidString, destinationWallet: defaultWallets.randomElement()!.id.uuidString),
            Transaction(category: categories.randomElement()!.id.uuidString, date: Date(), amount: 901516, originWallet: defaultWallets.randomElement()!.id.uuidString, destinationWallet: defaultWallets.randomElement()!.id.uuidString),
            Transaction(category: categories.randomElement()!.id.uuidString, date: Date(), amount: 718896, originWallet: defaultWallets.randomElement()!.id.uuidString, destinationWallet: defaultWallets.randomElement()!.id.uuidString),
            Transaction(category: categories.randomElement()!.id.uuidString, date: Date(), amount: 711649, originWallet: defaultWallets.randomElement()!.id.uuidString, destinationWallet: defaultWallets.randomElement()!.id.uuidString),
            Transaction(category: categories.randomElement()!.id.uuidString, date: Date(), amount: 676829, originWallet: defaultWallets.randomElement()!.id.uuidString, destinationWallet: defaultWallets.randomElement()!.id.uuidString),
            Transaction(category: categories.randomElement()!.id.uuidString, date: Date(), amount: 35608, originWallet: defaultWallets.randomElement()!.id.uuidString, destinationWallet: defaultWallets.randomElement()!.id.uuidString),
            Transaction(category: categories.randomElement()!.id.uuidString, date: Date(), amount: 523968, originWallet: defaultWallets.randomElement()!.id.uuidString, destinationWallet: defaultWallets.randomElement()!.id.uuidString),
            Transaction(category: categories.randomElement()!.id.uuidString, date: Date(), amount: 823243, originWallet: defaultWallets.randomElement()!.id.uuidString, destinationWallet: defaultWallets.randomElement()!.id.uuidString),
        ]
    }
    
    func updateTransaction(transaction: Transaction) async throws {
        if let index = db.transactions.firstIndex(where: { $0 == transaction }){
            db.transactions[index] = transaction
        }
    }
    
    func deleteTransaction(transaction: Transaction) async throws {
        if let index = db.transactions.firstIndex(where: { $0 == transaction }){
            db.transactions.remove(at: index)
        }
    }
    
    func getTransactions(startDate: Date, endDate: Date) async throws -> [Transaction] {
        return db.transactions.filter({ $0.date < endDate.endOfDay && $0.date > startDate.startOfDay })
    }
    
    func createTransaction(transaction: Transaction) async throws {
        db.transactions.append(transaction)
    }
}
