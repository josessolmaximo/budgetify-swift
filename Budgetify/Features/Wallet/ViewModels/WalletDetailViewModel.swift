//
//  WalletDetailViewModel.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 25/11/22.
//

import Foundation
import OrderedCollections

@MainActor
class WalletDetailViewModel: ObservableObject {
    @Published var isWalletSheetShown = false
    
    @Published var transactions: OrderedDictionary<Date, [Transaction]> = [:]
    @Published var incomeTransactions: OrderedDictionary<Date, [Transaction]> = [:]
    @Published var expenseTransactions: OrderedDictionary<Date, [Transaction]> = [:]
    
    @Published var validSections: [Date] = []
    
    @Published var selectedTransaction: Transaction?
    
    @Published var totalAmounts: OrderedDictionary<Date, Double> = [:]
    @Published var incomeAmounts: OrderedDictionary<Date, Double> = [:]
    @Published var expenseAmounts: OrderedDictionary<Date, Double> = [:]
    
    @Published var currentPlot = ""
    @Published var currentDate = 0
    
    @Published var showPlot = false
    
    @Published var offsetX: CGFloat = 0
    @Published var offsetY: CGFloat = 0
    
    @Published var chartTab: ChartTab = .total
    
    @Published var loading = false
    
    let parentVM: WalletViewModel
    
    init(parentVM: WalletViewModel){
        self.parentVM = parentVM
    }
    
    func configureTransactions(transactions: OrderedDictionary<Date, [Transaction]>, wallet: Wallet){
        var amountChange: Double = 0
        
        var startDate = Date().startOfMonth().removedTime
        let endDate = Date()
        
        var dates: [Date] = []
        
        self.transactions = [:]
        
        while startDate < endDate {
            dates.append(startDate)
            startDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        }
        
        for startDate in dates.reversed() {
            let walletTransaction = transactions[startDate]?.filter {
                $0.originWallet == wallet.id.uuidString || ($0.destinationWallet == wallet.id.uuidString && $0.type == .transfer)
            } ?? []
            
            if !validSections.contains(startDate){
                validSections.append(startDate)
            }
            
            if !walletTransaction.isEmpty {
                self.transactions[startDate] = walletTransaction
                
                let expenseTransactions = walletTransaction.filter({$0.type == .expense || $0.type == .transfer && $0.originWallet == wallet.id.uuidString })
                let incomeTransactions = walletTransaction.filter({$0.type == .income || $0.type == .transfer && $0.destinationWallet == wallet.id.uuidString })
                
                if !expenseTransactions.isEmpty {
                    self.expenseTransactions[startDate] = expenseTransactions
                }
                
                if !incomeTransactions.isEmpty {
                    self.incomeTransactions[startDate] = incomeTransactions
                }
                
                var total: Decimal = 0
                var expenseTotal: Decimal = 0
                var incomeTotal: Decimal = 0
                
                for transaction in walletTransaction {
                    if transaction.type == .expense {
                        total -= transaction.amount ?? 0
                        expenseTotal -= transaction.amount ?? 0
                    } else if transaction.type == .income {
                        total += transaction.amount ?? 0
                        incomeTotal -= transaction.amount ?? 0
                    } else {
                        if transaction.originWallet == wallet.id.uuidString {
                            total -= transaction.amount ?? 0
                            expenseTotal -= transaction.amount ?? 0
                        } else {
                            total += transaction.amount ?? 0
                            incomeTotal -= transaction.amount ?? 0
                        }
                    }
                }
                
                expenseAmounts[startDate] = expenseTotal.doubleValue
                incomeAmounts[startDate] = incomeTotal.doubleValue
                totalAmounts[startDate] = wallet.amount.doubleValue - amountChange
                
                amountChange += total.doubleValue
            } else {
                expenseAmounts[startDate] = 0
                incomeAmounts[startDate] = 0
                totalAmounts[startDate] = wallet.amount.doubleValue - amountChange
            }
        }
    }
}
