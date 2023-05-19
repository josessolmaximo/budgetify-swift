//
//  TransactionViewModel.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 02/10/22.
//

import SwiftUI
import StoreKit
import OrderedCollections
import FirebaseCrashlytics

@MainActor
class TransactionViewModel: ObservableObject {
    @AppStorage("selectedUserId", store: .grouped) var selectedUserId: String = ""
    
    @Published var transactions: OrderedDictionary<Date, [Transaction]> = [:]
    
    @Published var selectedTransaction: Transaction?
    @Published var isSearchSheetShown = false
    
    @Published var startDate: Date = Date().startOfMonth().startOfDay
    @Published var endDate: Date = Date().endOfMonth().endOfDay
    
    @Published var filterType: FilterType = .monthly
    
    @Published var totalChange: Decimal = 0
    @Published var totalIncome: Decimal = 0
    @Published var totalExpense: Decimal = 0
    
    @Published var loading = false
    @Published var isAddingRecurringTransactions = false
    
    @Published var query = TransactionQuery()
    
    @Published var unfilteredTransactions: [Transaction] = []
    @Published var filteredTransactions: [Transaction] = []
    
    let transactionService: TransactionServiceProtocol
    let walletService: WalletServiceProtocol
    let budgetService: BudgetServiceProtocol
    let imageService: ImageServiceProtocol
    
    init(transactionService: TransactionServiceProtocol, walletService: WalletServiceProtocol, budgetService: BudgetServiceProtocol, imageService: ImageServiceProtocol) {
        self.transactionService = transactionService
        self.walletService = walletService
        self.budgetService = budgetService
        self.imageService = imageService
        
        guard !selectedUserId.isEmpty else { return }
        
        Task {
            await getTransactions(wallets: [], categories: [])
        }
    }
    
    func setup(wallets: [Wallet], categories: [Category], isReport: Bool){
        query.wallets = Dictionary(uniqueKeysWithValues: wallets.map({ ($0, true) }))
        query.categories = Dictionary(uniqueKeysWithValues: categories.map({ ($0, true) }))
        
        query.transactionType[.expense] = true
        query.transactionType[.income] = !isReport
        query.transactionType[.transfer] = !isReport
    }
    
    func filterTransactions(transactions: [Transaction], wallets: [Wallet], categories: [Category], isReport: Bool = false){
        var filteredTransactions: [Transaction] = transactions
        
        if !query.transactionType.isEmpty {
            let selectedTypes = query.transactionType.filter({$0.value}).map({$0.key})
            filteredTransactions = filteredTransactions.filter({selectedTypes.contains($0.type)})
        }
        
        if !query.wallets.isEmpty {
            let selectedWallets = query.wallets.filter({$0.value}).map({$0.key.id.uuidString})
            filteredTransactions = filteredTransactions.filter({
                return selectedWallets.contains($0.originWallet) || (selectedWallets.contains($0.destinationWallet) && $0.type == .transfer)
            })
        }
        
        if !query.categories.isEmpty {
            let selectedCategories = query.categories.filter({$0.value}).map({$0.key.id.uuidString})
            filteredTransactions = filteredTransactions.filter({selectedCategories.contains($0.category) || $0.type == .transfer})
        }
        
        if !query.keyword.isEmpty {
            let lowercaseKeyword = query.keyword.lowercased()
            
            filteredTransactions = filteredTransactions.filter({ transaction in
                let category = categories.first(where: { $0.id.uuidString == transaction.category })
                let originWallet = wallets.first(where: { $0.id.uuidString == transaction.originWallet })
                let destinationWallet = wallets.first(where: { $0.id.uuidString == transaction.destinationWallet })
                
                return transaction.note.lowercased().contains(lowercaseKeyword) ||
                category?.name.lowercased().contains(lowercaseKeyword) ?? false ||
                transaction.location.name.lowercased().contains(lowercaseKeyword) ||
                originWallet?.name.lowercased().contains(lowercaseKeyword) ?? false ||
                destinationWallet?.name.lowercased().contains(lowercaseKeyword) ?? false
            })
        }
        
        var sections: OrderedDictionary<Date, [Transaction]> = [:]
        
        var totalChange: Decimal = 0
        var totalIncome: Decimal = 0
        var totalExpense: Decimal = 0
        
        for transaction in filteredTransactions {
//            sections[transaction.date.removedTime, default: []].insert(transaction, at: 0)
            sections[transaction.date.removedTime, default: []].append(transaction)
            if transaction.type == .expense {
                totalChange -= transaction.amount ?? 0
                totalExpense += transaction.amount ?? 0
            } else if transaction.type == .income {
                totalChange += transaction.amount ?? 0
                totalIncome += transaction.amount ?? 0
            }
        }
        
        self.filteredTransactions = filteredTransactions
        self.transactions = sections
        self.totalChange = totalChange
        self.totalIncome = totalIncome
        self.totalExpense = totalExpense
    }
    
    func changePeriodType(type: FilterType){
        filterType = type
        
        switch type {
        case .monthly:
            startDate = Date().startOfMonth().startOfDay
            endDate = Date().endOfMonth().endOfDay
        case .weekly:
            startDate = Date().startOfWeek.startOfDay
            endDate = Date().endOfWeek.endOfDay
        case .daily:
            startDate = Date().startOfDay
            endDate = Date().endOfDay
        case .custom:
            break
        case .yearly:
            startDate = Date().startOfYear.startOfDay
            endDate = Date().endOfYear.endOfMonth().endOfDay
        }
    }
    
    func changePeriod(change: PeriodChange){
        switch  filterType {
        case .monthly:
            let prevDate = Calendar.current.date(byAdding: .month, value: change == .previous ? -1 : 1, to: startDate)!
            
            startDate = prevDate.startOfMonth().startOfDay
            endDate = prevDate.endOfMonth().endOfDay
        case .weekly:
            let prevDate = Calendar.current.date(byAdding: .weekOfYear, value: change == .previous ? -1 : 1, to: startDate)!
            
            startDate = prevDate.startOfWeek.startOfDay
            endDate = prevDate.endOfWeek.endOfDay
        case .daily:
            let prevDate = Calendar.current.date(byAdding: .day, value: change == .previous ? -1 : 1, to: startDate)!
            
            startDate = prevDate.startOfDay
            endDate = prevDate.endOfDay
        case .custom:
            let interval =  startDate.distance(to: endDate) + 60 * 60 * 24
            
            startDate = startDate.addingTimeInterval(change == .previous ? -interval : interval)
            endDate =  endDate.addingTimeInterval(change == .previous ? -interval : interval)
        case .yearly:
            let prevDate = Calendar.current.date(byAdding: .year, value: change == .previous ? -1 : 1, to: startDate)!
            
            startDate = prevDate.startOfYear.startOfDay
            endDate = prevDate.endOfYear.endOfMonth().endOfDay
        }
    }
    
    func getTransactions(wallets: [Wallet], categories: [Category]) async {
        guard !loading else { return }
        
        loading = true
        
        ErrorManager.shared.logRequest(vm: self)
        
        do {
            let transactions = try await transactionService.getTransactions(startDate: startDate, endDate: endDate)
            unfilteredTransactions = transactions
            filterTransactions(transactions: transactions, wallets: wallets, categories: categories)
            
            if startDate == Date().startOfMonth().startOfDay &&
                endDate == Date().endOfMonth().endOfDay {
                WidgetDataManager.setTransactions(transactions: transactions)
            }
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
        
        loading = false
    }
    
    func getWidgetTransactions() async {
        do {
            let transactions = try await transactionService.getTransactions(startDate: startDate, endDate: endDate)
        } catch {
            ErrorManager.shared.logError(error: error, showAsAlert: false, vm: self)
        }
    }
    
    func deleteTransaction(transaction: Transaction, walletVM: WalletViewModel, budgetVM: BudgetViewModel, categoryVM: CategoryViewModel) async {
        ErrorManager.shared.logRequest(vm: self)
        
        if !transaction.images.isEmpty && transaction.recurring.type == .none {
            for imageId in transaction.images {
                try? await imageService.deleteImage(id: imageId)
            }
        }
        
        do {
            if transaction.type == .expense {
                for budgetId in transaction.budgetRefs {
                    guard var budget = budgetVM.budgets.first(where: { $0.id.uuidString == budgetId }) else { continue }
                    
                    if budget.range.contains(transaction.date){
                        try await budgetService.updateBudgetAmount(id: budget.id.uuidString, amount: -(transaction.amount?.doubleValue ?? 0))
                    } else {
                        guard let historyIndex = budget.history.firstIndex(where: { $0.range.contains(transaction.date) }) else { continue }
                        
                        budget.history[historyIndex].spentAmount -= transaction.amount ?? 0
                        
                        try await budgetService.updateBudgetHistory(id: budget.id.uuidString, history: budget.history)
                    }
                }
            }
            
            try await transactionService.deleteTransaction(transaction: transaction)
            
            let increment = transaction.type == .income ? -(transaction.amount?.doubleValue ?? 0) : transaction.amount?.doubleValue ?? 0
            
            if transaction.type == .transfer {
                if walletVM.wallets.contains(where: {$0.id.uuidString == transaction.originWallet}){
                    try await walletService.updateWalletAmount(id: transaction.originWallet, amount: transaction.amount?.doubleValue ?? 0)
                }
                if walletVM.wallets.contains(where: {$0.id.uuidString == transaction.destinationWallet}){
                    try await walletService.updateWalletAmount(id: transaction.destinationWallet, amount: -(transaction.amount?.doubleValue ?? 0))
                }
                
            } else {
                if walletVM.wallets.contains(where: {$0.id.uuidString == transaction.originWallet}){
                    try await walletService.updateWalletAmount(id: transaction.originWallet, amount: increment)
                }
            }
            
            await getTransactions(wallets: walletVM.wallets, categories: categoryVM.allCategories)
            await walletVM.getWallets()
            await budgetVM.getBudgets()
            
            AnalyticService.incrementUserProperty(.transactions, value: -1)
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
    }
    
    func addTransactions(transactions: [Transaction],
                         walletVM: WalletViewModel,
                         budgetVM: BudgetViewModel,
                         categoryVM: CategoryViewModel,
                         recurringVM: RecurringViewModel
    ) async {
        ErrorManager.shared.logRequest(vm: self)
        
        do {
            var mutableTransactions = transactions
            
            let recurringTransactions = transactions.filter({ return $0.recurring.type != .none })
            
            if recurringTransactions.count > 0 {
                try await recurringVM.recurringService.addRecurringTransaction(transactions: recurringTransactions)
            }
            
            var walletChanges: [String: Decimal] = [:]
            
            for budget in budgetVM.budgets {
                let budgetRange = budget.startDate...budget.endDate
                
                let newTransactions = transactions.filter({ transaction in
                    budget.categories.contains(transaction.category) && budgetRange.contains(transaction.date)
                })
                
                for transaction in newTransactions {
                    if transaction.type == .expense {
                        try await budgetVM.budgetService.updateBudgetAmount(id: budget.id.uuidString, amount: transaction.amount?.doubleValue ?? 0)
                        
                        if let index = mutableTransactions.firstIndex(where: { $0 == transaction }){
                            mutableTransactions[index].budgetRefs.append(budget.id.uuidString)
                        }
                    }
                }
            }
            
            for var transaction in mutableTransactions {
                if transaction.recurring.repeated != 0 {
                    transaction.id = UUID()
                }
                
                transaction.tags = transaction.note.split(separator: " ").filter({ $0.prefix(1) == "#" }).map(String.init)
                
                if !transaction.imagesData.isEmpty && transaction.recurring.repeated == 0 {
                    try await imageService.uploadImage(transaction: transaction)
                }
                
                transaction.imagesData = []
                
                if transaction.type == .expense {
                    walletChanges[transaction.originWallet, default: 0] -= transaction.amount ?? 0
                } else if transaction.type == .income {
                    walletChanges[transaction.originWallet, default: 0] += transaction.amount ?? 0
                } else if transaction.type == .transfer {
                    walletChanges[transaction.originWallet, default: 0] -= transaction.amount ?? 0
                    walletChanges[transaction.destinationWallet, default: 0] += transaction.amount ?? 0
                }
                
                try await transactionService.createTransaction(transaction: transaction)
            }
            
            for (walletId, change) in walletChanges {
                try await walletVM.walletService.updateWalletAmount(id: walletId, amount: change.doubleValue)
            }
            
            await getTransactions(wallets: walletVM.wallets, categories: categoryVM.allCategories)
            await walletVM.getWallets()
            await budgetVM.getBudgets()
            
            if transactions.filter({ $0.recurring.type != .none }).count > 0 {
                await recurringVM.getTransactions()
            }
            
            AnalyticService.incrementUserProperty(.transactions, value: transactions.count)
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
    }
    
    func updateTransaction(transaction: Transaction, uneditedTransaction: Transaction, walletVM: WalletViewModel, budgetVM: BudgetViewModel, categoryVM: CategoryViewModel) async {
        ErrorManager.shared.logRequest(vm: self)
        
        var transaction = transaction
        
        let difference: Double = (uneditedTransaction.amount?.doubleValue ?? 0) - (transaction.amount?.doubleValue ?? 0)
        
        if !uneditedTransaction.images.isEmpty {
            try? await imageService.updateImage(uneditedTransaction: uneditedTransaction, transaction: transaction)
        }
        
        transaction.tags = transaction.note.split(separator: " ").filter({ $0.prefix(1) == "#" }).map(String.init)
        
        transaction.imagesData = []
        
        do {
            if transaction.type == .expense {
                for budget in budgetVM.budgets {
                    var mutableBudget = budget
                    var historyChanged = false
                    
                    if transaction.budgetRefs.contains(budget.id.uuidString) {
                        if budget.range.contains(uneditedTransaction.date) {
                            if budget.categories.contains(uneditedTransaction.category) {
                                mutableBudget.spentAmount -= uneditedTransaction.amount ?? 0
                                transaction.budgetRefs = transaction.budgetRefs.filter({$0 != budget.id.uuidString})
                            }
                        } else {
                            if let index = budget.history.firstIndex(where: {$0.range.contains(uneditedTransaction.date)}) {
                                if mutableBudget.history[index].categories.contains(uneditedTransaction.category) {
                                    mutableBudget.history[index].spentAmount -= uneditedTransaction.amount ?? 0
                                    historyChanged = true
                                    transaction.budgetRefs = transaction.budgetRefs.filter({$0 != budget.id.uuidString})
                                }
                            }
                        }
                    }
                    
                    if budget.range.contains(transaction.date) {
                        if budget.categories.contains(transaction.category) {
                            mutableBudget.spentAmount += transaction.amount ?? 0
                            transaction.budgetRefs.append(budget.id.uuidString)
                        }
                    } else {
                        if let index = budget.history.firstIndex(where: {$0.range.contains(transaction.date)}) {
                            if mutableBudget.history[index].categories.contains(transaction.category) {
                                mutableBudget.history[index].spentAmount += transaction.amount ?? 0
                                historyChanged = true
                                transaction.budgetRefs.append(budget.id.uuidString)
                            }
                        }
                    }
                    
                    if mutableBudget.spentAmount != budget.spentAmount {
                        let difference = mutableBudget.spentAmount - budget.spentAmount
                        try await budgetService.updateBudgetAmount(id: budget.id.uuidString, amount: difference.doubleValue)
                    }
                    
                    if historyChanged {
                        try await budgetService.updateBudgetHistory(id: budget.id.uuidString, history: mutableBudget.history)
                    }
                }
            }
            
            try await transactionService.updateTransaction(transaction: transaction)
            
            let increment = transaction.type == .income ? -(difference) : difference
            
            if transaction.type == .transfer {
                
                if transaction.originWallet == uneditedTransaction.originWallet {
                    if walletVM.wallets.contains(where: {$0.id.uuidString == transaction.originWallet}) {
                        try await walletService.updateWalletAmount(id: transaction.originWallet, amount: increment)
                    }
                } else {
                    if walletVM.wallets.contains(where: {$0.id.uuidString == transaction.originWallet}) {
                        try await walletService.updateWalletAmount(id: transaction.originWallet, amount: -(transaction.amount?.doubleValue ?? 0))
                    }
                    
                    if walletVM.wallets.contains(where: {$0.id.uuidString == uneditedTransaction.originWallet}) {
                        try await walletService.updateWalletAmount(id: uneditedTransaction.originWallet, amount: uneditedTransaction.amount?.doubleValue ?? 0)
                    }
                }
                
                if transaction.destinationWallet == uneditedTransaction.destinationWallet {
                    if walletVM.wallets.contains(where: {$0.id.uuidString == transaction.destinationWallet}) {
                        try await walletService.updateWalletAmount(id: transaction.destinationWallet, amount: -increment)
                    }
                    
                } else {
                    if walletVM.wallets.contains(where: {$0.id.uuidString == transaction.destinationWallet}) {
                        try await walletService.updateWalletAmount(id: transaction.destinationWallet, amount: transaction.amount?.doubleValue ?? 0)
                    }
                    
                    if walletVM.wallets.contains(where: {$0.id.uuidString == uneditedTransaction.destinationWallet}) {
                        try await walletService.updateWalletAmount(id: uneditedTransaction.destinationWallet, amount: -(uneditedTransaction.amount?.doubleValue ?? 0))
                    }
                    
                }
            } else {
                if transaction.originWallet == uneditedTransaction.originWallet {
                    if walletVM.wallets.contains(where: {$0.id.uuidString == transaction.originWallet}) {
                        try await walletService.updateWalletAmount(id: transaction.originWallet, amount: increment)
                    }
                } else {
                    let amount = transaction.type == .expense ? -(transaction.amount?.doubleValue ?? 0) : transaction.amount?.doubleValue ?? 0
                    let uneditedAmount = uneditedTransaction.type == .income ? -(uneditedTransaction.amount?.doubleValue ?? 0) : uneditedTransaction.amount?.doubleValue ?? 0
                    
                    if walletVM.wallets.contains(where: {$0.id.uuidString == transaction.originWallet}) {
                        try await walletService.updateWalletAmount(id: transaction.originWallet, amount: amount)
                    }
                    
                    if walletVM.wallets.contains(where: {$0.id.uuidString == uneditedTransaction.originWallet}){
                        try await walletService.updateWalletAmount(id: uneditedTransaction.originWallet, amount: uneditedAmount)
                    }
                }
            }
            
            await getTransactions(wallets: walletVM.wallets, categories: categoryVM.allCategories)
            await walletVM.getWallets()
            await budgetVM.getBudgets()
            
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
    }
    
    func getBudgetTransactions(budget: Budget, history: BudgetHistory) async -> [Transaction] {
        ErrorManager.shared.logRequest(vm: self)
        
        do {
            let transactions = try await transactionService.getTransactions(startDate: history.startDate, endDate: history.endDate)

            return transactions.filter({ transaction in
                history.categories.contains(transaction.category) && transaction.type == .expense && transaction.budgetRefs.contains(budget.id.uuidString)
            })
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
            return []
        }
    }
    
    func getWalletTransactions(startDate: Date, endDate: Date) async -> OrderedDictionary<Date, [Transaction]> {
        do {
            let transactions = try await transactionService.getTransactions(startDate: startDate, endDate: endDate)
            
            var orderedTransactions: OrderedDictionary<Date, [Transaction]> = [:]
            
            for transaction in transactions {
                orderedTransactions[transaction.date.removedTime, default: []].append(transaction)
            }
            
            return orderedTransactions
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
            return [:]
        }
    }
}


