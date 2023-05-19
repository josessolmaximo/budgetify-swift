//
//  RecurringViewModel.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 16/11/22.
//

import SwiftUI
import OrderedCollections

@MainActor
class RecurringViewModel: ObservableObject {
    @AppStorage("selectedUserId", store: .grouped) var selectedUserId: String = ""
    
    @Published var organizedTransactions: OrderedDictionary<String, [Transaction]> = [:]
    @Published var allTransactions: [Transaction] = []
    
    @Published var selectedTransaction: Transaction?
    
    @Published var loading = false
    
    let recurringService: RecurringServiceProtocol
    
    init(recurringService: RecurringServiceProtocol){
        self.recurringService = recurringService
        
        guard !selectedUserId.isEmpty else { return }
        
        Task {
            await getTransactions()
        }
    }
    
    func countUpcomingTransactions() -> Int {
        guard let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: Date()) else {
            return 0
        }
        
        return allTransactions.filter({$0.recurring.date < nextWeek}).count
    }
    
    func getTransactions() async {
        ErrorManager.shared.logRequest(vm: self)
        
        loading = true
        
        do {
            allTransactions = try await recurringService.getRecurringTransactions()
            
            organizeRecurringTransactions()
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
        
        loading = false
    }
    
    func deleteTransaction(transaction: Transaction) async {
        ErrorManager.shared.logRequest(vm: self)
        
        loading = true
        
        do {
            try await recurringService.deleteRecurringTransaction(transaction: transaction)
            
            await getTransactions()
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
        
        loading = false
    }
    
    func checkDueTransactions() -> [Transaction] {
        return allTransactions.filter({ $0.recurring.date < Date().startOfDay })
    }
    
    func organizeRecurringTransactions(){
        organizedTransactions = [:]
        
        for transaction in allTransactions.sorted(by: { $0.recurring.date.compare($1.recurring.date) == .orderedAscending }) {
            let difference = Calendar.current.dateComponents([.day], from: Date(), to: transaction.recurring.date).day

            if let difference = difference {
                if transaction.recurring.date.startOfDay == Date().startOfDay {
                    organizedTransactions["Due today", default: []].append(transaction)
                } else if difference == 0 {
                    organizedTransactions["Due tomorrow", default: []].append(transaction)
                } else if difference < 30 {
                    organizedTransactions["Due in \(difference + 1) days", default: []].append(transaction)
                } else {
                    if let monthDifference = Calendar.current.dateComponents([.month], from: Date(), to: transaction.recurring.date).month {
                        if monthDifference == 0 {
                            organizedTransactions["Due next month", default: []].append(transaction)
                        } else {
                            organizedTransactions["Due in \(monthDifference + 1) months", default: []].append(transaction)
                        }
                    }
                }
            }
        }
    }
}
