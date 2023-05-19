//
//  TransactionSheetViewModel.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 03/12/22.
//

import SwiftUI
import StoreKit

enum FocusedField {
    case location
    case note
    case amount
    case locationSearch
}

@MainActor
class TransactionSheetViewModel: ObservableObject {
    @AppStorage("transactionsAdded", store: .grouped) var transactionsAdded = 0
    @AppStorage("requestedRating", store: .grouped) var requestedRating = false
    
    @Published var transactions: [Transaction] = []
    
    @Published var shouldSheetDismiss = false
    
    @Published var isMapSheetShown = false
    @Published var isCameraSheetShown: String?
    @Published var isPhotoSheetShown = false
    
    @Published var loading = false
    
    @Published var canDismiss = true
    
    let doesTransactionExist: Bool
    let isRecurringMode: Bool
    
    let uneditedTransaction: Transaction
    
    init(transactions: [Transaction],
         isViewMode: Bool,
         isRecurringMode: Bool
    ){
        self.transactions = transactions
        self.doesTransactionExist = isViewMode
        self.isRecurringMode = isRecurringMode
        
        
        // TODO: Change this to an optional
        if let firstTransaction = transactions.first {
            self.uneditedTransaction = firstTransaction
        } else {
            self.uneditedTransaction = .init(category: "", originWallet: "", destinationWallet: "")
        }
    }
    
    func addTransactions(transactionVM: TransactionViewModel, walletVM: WalletViewModel, budgetVM: BudgetViewModel, recurringVM: RecurringViewModel, categoryVM: CategoryViewModel) async {
        loading = true
        
        ErrorManager.shared.logRequest(vm: self)
        
        await transactionVM.addTransactions(transactions: transactions, walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM, recurringVM: recurringVM)
        
        if !ErrorManager.shared.isErrorShown {
            shouldSheetDismiss = true
            
            if !requestedRating {
                transactionsAdded += 1
                
                if transactionsAdded > ConfigManager.shared.transactionRatingLimit {
                    var windowKey: UIWindow? {
                        UIApplication.shared.connectedScenes.flatMap { ($0 as? UIWindowScene)?.windows ?? [] }.first { $0.isKeyWindow }
                    }
                    
                    guard let windowScene = windowKey?.windowScene else { return }
                    
                    SKStoreReviewController.requestReview(in: windowScene)
                    
                    requestedRating = true
                    
                    AnalyticService.updateUserProperty(.requestedRating, value: true)
                }
            }
        }
        
        loading = false
    }
    
    func updateTransactions(transactionVM: TransactionViewModel,
                            recurringVM: RecurringViewModel,
                            walletVM: WalletViewModel,
                            budgetVM: BudgetViewModel,
                            categoryVM: CategoryViewModel
    ) async {
        loading = true
        
        ErrorManager.shared.logRequest(vm: self)
        
        do {
            guard let transaction = transactions.first else { return }
            
            if isRecurringMode && doesTransactionExist {
                try await recurringVM.recurringService.updateRecurringTransaction(transaction: transaction)
                
                await transactionVM.getTransactions(wallets: walletVM.wallets, categories: categoryVM.allCategories)
                await recurringVM.getTransactions()
            } else {
                await transactionVM.updateTransaction(transaction: transaction, uneditedTransaction: uneditedTransaction, walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM)
            }
            
            if !ErrorManager.shared.isErrorShown {
                shouldSheetDismiss = true
            }
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
        
        loading = false
    }
    
    func deleteTransaction(transactionVM: TransactionViewModel, walletVM: WalletViewModel, budgetVM: BudgetViewModel, categoryVM: CategoryViewModel) async {
        loading = true
        
        ErrorManager.shared.logRequest(vm: self)
        
        do {
            guard let transaction = transactions.first else { return }
        
            await transactionVM.deleteTransaction(transaction: transaction, walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM)
            
            await transactionVM.getTransactions(wallets: walletVM.wallets, categories: categoryVM.allCategories)
            await walletVM.getWallets()
            await budgetVM.getBudgets()
            
            shouldSheetDismiss = true
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
        
        loading = false
    }
    
    func deleteRecurringTransaction(recurringVM: RecurringViewModel) async {
        loading = true
        
        ErrorManager.shared.logRequest(vm: self)
        
        do {
            guard let transaction = transactions.first else { return }
        
            await recurringVM.deleteTransaction(transaction: transaction)
            
            shouldSheetDismiss = true
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
        
        loading = false
    }
}
