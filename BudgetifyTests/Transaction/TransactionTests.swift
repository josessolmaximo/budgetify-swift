//
//  TransactionTests.swift
//  BudgetifyTests
//
//  Created by Joses Solmaximo on 08/02/23.
//

import XCTest
@testable import Budgetify

@MainActor
final class TransactionTests: XCTestCase {
    private var db: MockDatabase!
    
    private var vm: TransactionViewModel!
    private var walletVM: WalletViewModel!
    private var budgetVM: BudgetViewModel!
    private var categoryVM: CategoryViewModel!
    private var recurringVM: RecurringViewModel!
    
    override func setUp() async throws {
        let db = MockDatabase()
        
        let transactionService = MockTransactionService(db: db)
        let walletService = MockWalletService(db: db)
        let budgetService = MockBudgetService(db: db)
        let recurringService = MockRecurringService()
        let categoryService = MockCategoryService()
        let imageService = MockImageService()
        
        self.db = db
        
        vm = TransactionViewModel(transactionService: transactionService, walletService: walletService, budgetService: budgetService, imageService: imageService)
        walletVM = WalletViewModel(walletService: walletService)
        budgetVM = BudgetViewModel(budgetService: budgetService)
        categoryVM = CategoryViewModel(categoryService: categoryService)
        recurringVM = RecurringViewModel(recurringService: recurringService)
        
        await budgetVM.getBudgets()
    }
    
    override func tearDown() {
        db = nil
        vm = nil
        walletVM = nil
        budgetVM = nil
        categoryVM = nil
        recurringVM = nil
    }
    
    func test_create_expense_transaction() async throws {
        let transactions = [
            Transaction(category: "61B92A61-588E-4C9F-A63D-74AB6F4D7A4F", amount: 1000, originWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", destinationWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE"),
            Transaction(category: "", amount: 1000, originWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", destinationWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE"),
            Transaction(category: "61B92A61-588E-4C9F-A63D-74AB6F4D7A4F", date: Calendar.current.date(byAdding: .year, value: 1, to: Date())!, amount: 1000, originWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", destinationWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE")
        ]
        
        await vm.addTransactions(transactions: transactions, walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM, recurringVM: recurringVM)
        
        for transaction in transactions {
            XCTAssertTrue(db.transactions.contains(transaction))
        }
        
        XCTAssertEqual(db.wallets[0].amount, 0 - 3000)
        XCTAssertEqual(db.budgets[0].spentAmount, 0 + 1000)
    }
    
    func test_create_income_transaction() async throws {
        let transactions = [
            Transaction(category: "61B92A61-588E-4C9F-A63D-74AB6F4D7A4F", amount: 1000, originWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", destinationWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", type: .income),
            Transaction(category: "", amount: 1000, originWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", destinationWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", type: .income),
            Transaction(category: "61B92A61-588E-4C9F-A63D-74AB6F4D7A4F", date: Calendar.current.date(byAdding: .year, value: 1, to: Date())!, amount: 1000, originWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", destinationWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", type: .income)
        ]
        
        await vm.addTransactions(transactions: transactions, walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM, recurringVM: recurringVM)
        
        for transaction in transactions {
            XCTAssertTrue(db.transactions.contains(transaction))
        }
        
        XCTAssertEqual(db.wallets[0].amount, 0 + 3000)
        XCTAssertEqual(db.budgets[0].spentAmount, 0)
    }
    
    func test_create_transfer_transaction() async throws {
        let transactions = [
            Transaction(category: "", amount: 1000, originWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", destinationWallet: "16E94948-B52B-4F4C-AA57-051614BAC5F5", type: .transfer)
        ]
        
        await vm.addTransactions(transactions: transactions, walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM, recurringVM: recurringVM)
        
        for transaction in transactions {
            XCTAssertTrue(db.transactions.contains(transaction))
        }
        
        XCTAssertEqual(db.wallets[0].amount, 0 - 1000)
        XCTAssertEqual(db.wallets[1].amount, 5100.52 + 1000)
    }
    
    func test_create_transactions() async throws {
        let transactions = [
            Transaction(category: "61B92A61-588E-4C9F-A63D-74AB6F4D7A4F", amount: 1000.151, originWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", destinationWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE"),
            Transaction(category: "61B92A61-588E-4C9F-A63D-74AB6F4D7A4F", amount: 1000.5161, originWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", destinationWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE"),
            Transaction(category: "61B92A61-588E-4C9F-A63D-74AB6F4D7A4F", amount: 1000.35261, originWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", destinationWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE"),
            Transaction(category: "", amount: 1000.9876, originWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", destinationWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE"),
            Transaction(category: "A6F32E6E-26B7-4A9E-B7B5-E4C85B2812F5", amount: 1000.8657, originWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", destinationWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", type: .income),
        ]
        
        await vm.addTransactions(transactions: transactions, walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM, recurringVM: recurringVM)
        
        for transaction in transactions {
            XCTAssertTrue(db.transactions.contains(transaction))
        }
        
        XCTAssertEqual(db.wallets[0].amount, -Decimal(1000.151 + 1000.5161 + 1000.35261 + 1000.9876 - 1000.8657))
        XCTAssertEqual(db.budgets[0].spentAmount, Decimal(1000.151 + 1000.5161 + 1000.35261), accuracy: 0.0000001)
    }
    
    func test_update_expense_transaction_increase_amount() async throws {
        let uneditedTransaction = Transaction(category: "61B92A61-588E-4C9F-A63D-74AB6F4D7A4F", amount: 1000, originWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", destinationWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE")
        
        await vm.addTransactions(transactions: [uneditedTransaction], walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM, recurringVM: recurringVM)
        
        XCTAssertTrue(db.transactions.contains(uneditedTransaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 - 1000)
        XCTAssertEqual(db.budgets[0].spentAmount, 1000)
        
        var editedTransaction: Transaction {
            var transaction = db.transactions.first(where: {$0 == uneditedTransaction})!
            transaction.amount = 2000
            return transaction
        }
        
        await vm.updateTransaction(transaction: editedTransaction, uneditedTransaction: uneditedTransaction, walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM)
        
        XCTAssertTrue(db.transactions.contains(editedTransaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 - 2000)
        XCTAssertEqual(db.budgets[0].spentAmount, 2000)
    }
    
    func test_update_expense_transaction_decrease_amount() async throws {
        let uneditedTransaction = Transaction(category: "61B92A61-588E-4C9F-A63D-74AB6F4D7A4F", amount: 1000, originWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", destinationWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE")
        
        await vm.addTransactions(transactions: [uneditedTransaction], walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM, recurringVM: recurringVM)
        
        XCTAssertTrue(db.transactions.contains(uneditedTransaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 - 1000)
        XCTAssertEqual(db.budgets[0].spentAmount, 1000)
        
        var editedTransaction: Transaction {
            var transaction = db.transactions.first(where: {$0 == uneditedTransaction})!
            transaction.amount = 500
            return transaction
        }
        
        await vm.updateTransaction(transaction: editedTransaction, uneditedTransaction: uneditedTransaction, walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM)
        
        
        XCTAssertTrue(db.transactions.contains(editedTransaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 - 500)
        XCTAssertEqual(db.budgets[0].spentAmount, 500)
    }
    
    func test_update_expense_transaction_decrease_amount_change_wallet() async throws {
        let uneditedTransaction = Transaction(category: "61B92A61-588E-4C9F-A63D-74AB6F4D7A4F", amount: 1000, originWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", destinationWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE")
        
        await vm.addTransactions(transactions: [uneditedTransaction], walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM, recurringVM: recurringVM)
        
        XCTAssertTrue(db.transactions.contains(uneditedTransaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 - 1000)
        XCTAssertEqual(db.budgets[0].spentAmount, 1000)
        
        var editedTransaction: Transaction {
            var transaction = db.transactions.first(where: {$0 == uneditedTransaction})!
            transaction.amount = 500
            transaction.originWallet = "16E94948-B52B-4F4C-AA57-051614BAC5F5"
            return transaction
        }
        
        await vm.updateTransaction(transaction: editedTransaction, uneditedTransaction: uneditedTransaction, walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM)
        
        
        XCTAssertTrue(db.transactions.contains(editedTransaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0)
        XCTAssertEqual(db.wallets[1].amount, 5100.52 - 500)
        XCTAssertEqual(db.budgets[0].spentAmount, 500)
    }
    
    func test_update_expense_transaction_decrease_amount_change_category() async throws {
        let uneditedTransaction = Transaction(category: "61B92A61-588E-4C9F-A63D-74AB6F4D7A4F", amount: 1000, originWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", destinationWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE")
        
        await vm.addTransactions(transactions: [uneditedTransaction], walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM, recurringVM: recurringVM)
        
        XCTAssertTrue(db.transactions.contains(uneditedTransaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 - 1000)
        XCTAssertEqual(db.budgets[0].spentAmount, 1000)
        XCTAssertEqual(db.budgets[1].spentAmount, 1000)
        
        var editedTransaction: Transaction {
            var transaction = db.transactions.first(where: {$0 == uneditedTransaction})!
            transaction.amount = 500
            transaction.category = "A6F32E6E-26B7-4A9E-B7B5-E4C85B2812F5"
            return transaction
        }
        
        await vm.updateTransaction(transaction: editedTransaction, uneditedTransaction: uneditedTransaction, walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM)
        
        
        XCTAssertTrue(db.transactions.contains(editedTransaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 - 500)
        XCTAssertEqual(db.budgets[0].spentAmount, 500)
        XCTAssertEqual(db.budgets[1].spentAmount, 0)
    }
    
    func test_update_expense_transaction_decrease_amount_invalid_budget() async throws {
        let uneditedTransaction = Transaction(category: "61B92A61-588E-4C9F-A63D-74AB6F4D7A4F", amount: 1000, originWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", destinationWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE")
        
        await vm.addTransactions(transactions: [uneditedTransaction], walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM, recurringVM: recurringVM)
        
        XCTAssertTrue(db.transactions.contains(uneditedTransaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 - 1000)
        XCTAssertEqual(db.budgets[0].spentAmount, 1000)
        XCTAssertEqual(db.budgets[1].spentAmount, 1000)
        
        var editedTransaction: Transaction {
            var transaction = db.transactions.first(where: {$0 == uneditedTransaction})!
            transaction.amount = 500
            transaction.category = "A6F32E6E-26B7-4A9E-B7B5-E4C85B2812F5"
            transaction.date = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
            return transaction
        }
        
        await vm.updateTransaction(transaction: editedTransaction, uneditedTransaction: uneditedTransaction, walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM)
        
        XCTAssertTrue(db.transactions.contains(editedTransaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 - 500)
        XCTAssertEqual(db.budgets[0].spentAmount, 0)
        XCTAssertEqual(db.budgets[1].spentAmount, 0)
    }
    
    
    
    func test_update_expense_transaction_decrease_amount_valid_budget() async throws {
        let uneditedTransaction = Transaction(category: "", amount: 1000, originWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", destinationWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE")
        
        await vm.addTransactions(transactions: [uneditedTransaction], walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM, recurringVM: recurringVM)
        
        XCTAssertTrue(db.transactions.contains(uneditedTransaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 - 1000)
        XCTAssertEqual(db.budgets[0].spentAmount, 0)
        XCTAssertEqual(db.budgets[1].spentAmount, 0)
        
        var editedTransaction: Transaction {
            var transaction = db.transactions.first(where: {$0 == uneditedTransaction})!
            transaction.amount = 500
            transaction.category = "61B92A61-588E-4C9F-A63D-74AB6F4D7A4F"
            return transaction
        }
        
        await vm.updateTransaction(transaction: editedTransaction, uneditedTransaction: uneditedTransaction, walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM)
        
        XCTAssertTrue(db.transactions.contains(editedTransaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 - 500)
        XCTAssertEqual(db.budgets[0].spentAmount, 500)
        XCTAssertEqual(db.budgets[1].spentAmount, 500)
    }
    
    func test_update_income_transaction_decrease_amount_change_wallet() async throws {
        let uneditedTransaction = Transaction(category: "61B92A61-588E-4C9F-A63D-74AB6F4D7A4F", amount: 1000, originWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", destinationWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", type: .income)
        
        await vm.addTransactions(transactions: [uneditedTransaction], walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM, recurringVM: recurringVM)
        
        XCTAssertTrue(db.transactions.contains(uneditedTransaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 + 1000)
        XCTAssertEqual(db.budgets[0].spentAmount, 0)
        
        var editedTransaction: Transaction {
            var transaction = uneditedTransaction
            transaction.amount = 500
            transaction.originWallet = "16E94948-B52B-4F4C-AA57-051614BAC5F5"
            return transaction
        }
        
        await vm.updateTransaction(transaction: editedTransaction, uneditedTransaction: uneditedTransaction, walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM)
        
        
        XCTAssertTrue(db.transactions.contains(editedTransaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0)
        XCTAssertEqual(db.wallets[1].amount, 5100.52 + 500)
        XCTAssertEqual(db.budgets[0].spentAmount, 0)
    }
    
    func test_update_income_transaction_increase_amount() async throws {
        let uneditedTransaction = Transaction(category: "61B92A61-588E-4C9F-A63D-74AB6F4D7A4F", amount: 1000, originWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", destinationWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", type: .income)
        
        await vm.addTransactions(transactions: [uneditedTransaction], walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM, recurringVM: recurringVM)
        
        XCTAssertTrue(db.transactions.contains(uneditedTransaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 + 1000)
        XCTAssertEqual(db.budgets[0].spentAmount, 0)
        
        var editedTransaction: Transaction {
            var transaction = uneditedTransaction
            transaction.amount = 2000
            return transaction
        }
        
        await vm.updateTransaction(transaction: editedTransaction, uneditedTransaction: uneditedTransaction, walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM)
        
        
        XCTAssertTrue(db.transactions.contains(editedTransaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 + 2000)
        XCTAssertEqual(db.budgets[0].spentAmount, 0)
    }
    
    func test_update_income_transaction_decrease_amount() async throws {
        let uneditedTransaction = Transaction(category: "61B92A61-588E-4C9F-A63D-74AB6F4D7A4F", amount: 1000, originWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", destinationWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", type: .income)
        
        await vm.addTransactions(transactions: [uneditedTransaction], walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM, recurringVM: recurringVM)
        
        XCTAssertTrue(db.transactions.contains(uneditedTransaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 + 1000)
        XCTAssertEqual(db.budgets[0].spentAmount, 0)
        
        var editedTransaction: Transaction {
            var transaction = uneditedTransaction
            transaction.amount = 500
            return transaction
        }
        
        await vm.updateTransaction(transaction: editedTransaction, uneditedTransaction: uneditedTransaction, walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM)
        
        
        XCTAssertTrue(db.transactions.contains(editedTransaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 + 500)
        XCTAssertEqual(db.budgets[0].spentAmount, 0)
    }
    
    func test_update_transfer_transaction_increase_amount() async throws {
        let uneditedTransaction = Transaction(category: "61B92A61-588E-4C9F-A63D-74AB6F4D7A4F", amount: 1000, originWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", destinationWallet: "16E94948-B52B-4F4C-AA57-051614BAC5F5", type: .transfer)
        
        await vm.addTransactions(transactions: [uneditedTransaction], walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM, recurringVM: recurringVM)
        
        XCTAssertTrue(db.transactions.contains(uneditedTransaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 - 1000)
        XCTAssertEqual(db.wallets[1].amount, 5100.52 + 1000)
        
        var editedTransaction: Transaction {
            var transaction = uneditedTransaction
            transaction.amount = 2000
            return transaction
        }
        
        await vm.updateTransaction(transaction: editedTransaction, uneditedTransaction: uneditedTransaction, walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM)
        
        
        XCTAssertTrue(db.transactions.contains(editedTransaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 - 2000)
        XCTAssertEqual(db.wallets[1].amount, 5100.52 + 2000)
    }
    
    func test_update_transfer_transaction_decrease_amount() async throws {
        let uneditedTransaction = Transaction(category: "61B92A61-588E-4C9F-A63D-74AB6F4D7A4F", amount: 1000, originWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", destinationWallet: "16E94948-B52B-4F4C-AA57-051614BAC5F5", type: .transfer)
        
        await vm.addTransactions(transactions: [uneditedTransaction], walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM, recurringVM: recurringVM)
        
        XCTAssertTrue(db.transactions.contains(uneditedTransaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 - 1000)
        XCTAssertEqual(db.wallets[1].amount, 5100.52 + 1000)
        
        var editedTransaction: Transaction {
            var transaction = uneditedTransaction
            transaction.amount = 500
            return transaction
        }
        
        await vm.updateTransaction(transaction: editedTransaction, uneditedTransaction: uneditedTransaction, walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM)
        
        
        XCTAssertTrue(db.transactions.contains(editedTransaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 - 500)
        XCTAssertEqual(db.wallets[1].amount, 5100.52 + 500)
    }
    
    func test_update_transfer_transaction_decrease_amount_change_wallet() async throws {
        let uneditedTransaction = Transaction(category: "61B92A61-588E-4C9F-A63D-74AB6F4D7A4F", amount: 1000, originWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", destinationWallet: "16E94948-B52B-4F4C-AA57-051614BAC5F5", type: .transfer)
        
        await vm.addTransactions(transactions: [uneditedTransaction], walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM, recurringVM: recurringVM)
        
        XCTAssertTrue(db.transactions.contains(uneditedTransaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 - 1000)
        XCTAssertEqual(db.wallets[1].amount, 5100.52 + 1000)
        
        var editedTransaction: Transaction {
            var transaction = uneditedTransaction
            transaction.amount = 500
            transaction.originWallet = "16E94948-B52B-4F4C-AA57-051614BAC5F5"
            transaction.destinationWallet = "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE"
            return transaction
        }
        
        await vm.updateTransaction(transaction: editedTransaction, uneditedTransaction: uneditedTransaction, walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM)
        
        
        XCTAssertTrue(db.transactions.contains(editedTransaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 + 500)
        XCTAssertEqual(db.wallets[1].amount, 5100.52 - 500)
    }
    
    func test_delete_expense_transaction() async throws {
        let transaction = Transaction(category: "61B92A61-588E-4C9F-A63D-74AB6F4D7A4F", amount: 1000, originWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", destinationWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE")
        
        await vm.addTransactions(transactions: [transaction], walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM, recurringVM: recurringVM)
    
        XCTAssertTrue(db.transactions.contains(transaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 - 1000)
        XCTAssertEqual(db.budgets[0].spentAmount, 1000)
        
        await vm.deleteTransaction(transaction: db.transactions.first(where: {$0 == transaction})!, walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM)
        
        XCTAssertFalse(vm.unfilteredTransactions.contains(transaction))
        XCTAssertFalse(db.transactions.contains(transaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0)
        XCTAssertEqual(db.budgets[0].spentAmount, 0)
    }
    
    func test_delete_expense_transaction_invalid_budget() async throws {
        let transaction = Transaction(category: "61B92A61-588E-4C9F-A63D-74AB6F4D7A4F",date: Calendar.current.date(byAdding: .year, value: 1, to: Date())!, amount: 1000, originWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", destinationWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE")
        
        await vm.addTransactions(transactions: [transaction], walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM, recurringVM: recurringVM)
    
        XCTAssertTrue(db.transactions.contains(transaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 - 1000)
        XCTAssertEqual(db.budgets[0].spentAmount, 0)
        
        await vm.deleteTransaction(transaction: db.transactions.first(where: {$0 == transaction})!, walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM)
        
        XCTAssertFalse(vm.unfilteredTransactions.contains(transaction))
        XCTAssertFalse(db.transactions.contains(transaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0)
        XCTAssertEqual(db.budgets[0].spentAmount, 0)
    }
    
    func test_delete_income_transaction() async throws {
        let transaction = Transaction(category: "61B92A61-588E-4C9F-A63D-74AB6F4D7A4F", amount: 1000, originWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", destinationWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", type: .income)
        
        await vm.addTransactions(transactions: [transaction], walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM, recurringVM: recurringVM)
    
        XCTAssertTrue(db.transactions.contains(transaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 + 1000)
        XCTAssertEqual(db.budgets[0].spentAmount, 0)
        
        await vm.deleteTransaction(transaction: transaction, walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM)
        
        XCTAssertFalse(vm.unfilteredTransactions.contains(transaction))
        XCTAssertFalse(db.transactions.contains(transaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0)
        XCTAssertEqual(db.budgets[0].spentAmount, 0)
    }
    
    func test_delete_transfer_transaction() async throws {
        let transaction = Transaction(category: "61B92A61-588E-4C9F-A63D-74AB6F4D7A4F", amount: 1000, originWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", destinationWallet: "16E94948-B52B-4F4C-AA57-051614BAC5F5", type: .transfer)
        
        await vm.addTransactions(transactions: [transaction], walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM, recurringVM: recurringVM)
    
        XCTAssertTrue(db.transactions.contains(transaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 - 1000)
        XCTAssertEqual(db.wallets[1].amount, 5100.52 + 1000)
        
        await vm.deleteTransaction(transaction: transaction, walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM)
        
        XCTAssertFalse(vm.unfilteredTransactions.contains(transaction))
        XCTAssertFalse(db.transactions.contains(transaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0)
        XCTAssertEqual(db.wallets[1].amount, 5100.52)
    }
    
    // Budget testing
    
    func test_delete_budget_previous_range() async throws {
        let transaction = Transaction(category: "61B92A61-588E-4C9F-A63D-74AB6F4D7A4F", amount: 1000, originWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", destinationWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE")
        
        await vm.addTransactions(transactions: [transaction], walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM, recurringVM: recurringVM)
    
        XCTAssertTrue(db.transactions.contains(transaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 - 1000)
        XCTAssertEqual(db.budgets[0].spentAmount, 1000)
        
        let nextBudget = db.budgets[0].nextPeriod
        await budgetVM.updateBudget(budget: nextBudget)
        
//        XCTAssertEqual(db.budgets[0].history[0].spentAmount, 1000)
        
        await vm.deleteTransaction(transaction: db.transactions.first(where: {$0 == transaction})!, walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM)
        
        XCTAssertFalse(vm.unfilteredTransactions.contains(transaction))
        XCTAssertFalse(db.transactions.contains(transaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0)
        XCTAssertEqual(db.budgets[0].spentAmount, 0)
        
//        XCTAssertEqual(db.budgets[0].history[0].spentAmount, 0)
        
        XCTAssertEqual(db.budgets[0].history.count, 1)
    }
    
    func test_update_budget_valid_range_invalid_category() async throws {
        let uneditedTransaction = Transaction(category: "61B92A61-588E-4C9F-A63D-74AB6F4D7A4F", amount: 1000, originWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", destinationWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE")
        
        await vm.addTransactions(transactions: [uneditedTransaction], walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM, recurringVM: recurringVM)
        
        XCTAssertTrue(db.transactions.contains(uneditedTransaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 - 1000)
        XCTAssertEqual(db.budgets[0].spentAmount, 1000)
        XCTAssertEqual(db.budgets[1].spentAmount, 1000)
        
        var editedTransaction: Transaction {
            var transaction = db.transactions.first(where: {$0 == uneditedTransaction})!
            transaction.amount = 500
            transaction.category = "A6F32E6E-26B7-4A9E-B7B5-E4C85B2812F5"
            return transaction
        }
        
        await vm.updateTransaction(transaction: editedTransaction, uneditedTransaction: uneditedTransaction, walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM)
        
        XCTAssertTrue(db.transactions.contains(editedTransaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 - 500)
        XCTAssertEqual(db.budgets[0].spentAmount, 500)
        XCTAssertEqual(db.budgets[1].spentAmount, 0)
    }
    
    func test_update_budget_current_to_current_range() async throws {
        let uneditedTransaction = Transaction(category: "61B92A61-588E-4C9F-A63D-74AB6F4D7A4F", date: Calendar.current.date(byAdding: .day, value: 7, to: Date())!, amount: 1000, originWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", destinationWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE")
        
        await vm.addTransactions(transactions: [uneditedTransaction], walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM, recurringVM: recurringVM)
        
        XCTAssertTrue(db.transactions.contains(uneditedTransaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 - 1000)
//        XCTAssertEqual(db.budgets[0].spentAmount, 1000)
        
        var editedTransaction: Transaction {
            var transaction = db.transactions.first(where: {$0 == uneditedTransaction})!
            transaction.date = Date()
            return transaction
        }
        
        await vm.updateTransaction(transaction: editedTransaction, uneditedTransaction: uneditedTransaction, walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM)
        
        XCTAssertTrue(db.transactions.contains(editedTransaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 - 1000)
        XCTAssertEqual(db.budgets[0].spentAmount, 1000)
    }
    
    func test_update_budget_current_to_previous_range() async throws {
        let nextBudget = db.budgets[0].nextPeriod
        await budgetVM.updateBudget(budget: nextBudget)
        
        let uneditedTransaction = Transaction(category: "61B92A61-588E-4C9F-A63D-74AB6F4D7A4F",date: Calendar.current.date(byAdding: .month, value: 1, to: Date())!, amount: 1000, originWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", destinationWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE")
        
        await vm.addTransactions(transactions: [uneditedTransaction], walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM, recurringVM: recurringVM)
        
        XCTAssertTrue(db.transactions.contains(uneditedTransaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 - 1000)
//        XCTAssertEqual(db.budgets[0].spentAmount, 1000)
        
        var editedTransaction: Transaction {
            var transaction = db.transactions.first(where: {$0 == uneditedTransaction})!
            transaction.amount = 500
            transaction.category = "A6F32E6E-26B7-4A9E-B7B5-E4C85B2812F5"
            transaction.date = Date()
            return transaction
        }
        
        await vm.updateTransaction(transaction: editedTransaction, uneditedTransaction: uneditedTransaction, walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM)
        
        XCTAssertTrue(db.transactions.contains(editedTransaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 - 500)
        XCTAssertEqual(db.budgets[0].spentAmount, 0)
//        XCTAssertEqual(db.budgets[0].history[0].spentAmount, 500)
        
        XCTAssertEqual(db.budgets[0].history.count, 1)
    }
    
    func test_update_budget_current_to_future_range() async throws {
        let uneditedTransaction = Transaction(category: "61B92A61-588E-4C9F-A63D-74AB6F4D7A4F", amount: 1000, originWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", destinationWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE")
        
        await vm.addTransactions(transactions: [uneditedTransaction], walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM, recurringVM: recurringVM)
        
        XCTAssertTrue(db.transactions.contains(uneditedTransaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 - 1000)
        XCTAssertEqual(db.budgets[0].spentAmount, 1000)
        
        var editedTransaction: Transaction {
            var transaction = db.transactions.first(where: {$0 == uneditedTransaction})!
            transaction.amount = 500
            transaction.category = "A6F32E6E-26B7-4A9E-B7B5-E4C85B2812F5"
            transaction.date = Calendar.current.date(byAdding: .month, value: 1, to: Date())!
            return transaction
        }
        
        await vm.updateTransaction(transaction: editedTransaction, uneditedTransaction: uneditedTransaction, walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM)
        
        XCTAssertTrue(db.transactions.contains(editedTransaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 - 500)
        XCTAssertEqual(db.budgets[0].spentAmount, 0)
        
//        XCTAssertEqual(db.budgets[0].history.count, 0)
    }
    
    func test_update_budget_previous_to_previous_range() async throws {
        let uneditedTransaction = Transaction(category: "61B92A61-588E-4C9F-A63D-74AB6F4D7A4F", amount: 1000, originWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", destinationWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE")
        
        await vm.addTransactions(transactions: [uneditedTransaction], walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM, recurringVM: recurringVM)
        
        XCTAssertTrue(db.transactions.contains(uneditedTransaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 - 1000)
        XCTAssertEqual(db.budgets[0].spentAmount, 1000)
        
        let nextBudget = db.budgets[0].nextPeriod
        await budgetVM.updateBudget(budget: nextBudget)
        
        var editedTransaction: Transaction {
            var transaction = db.transactions.first(where: {$0 == uneditedTransaction})!
            transaction.amount = 500
            transaction.category = "A6F32E6E-26B7-4A9E-B7B5-E4C85B2812F5"
            return transaction
        }
        
        await vm.updateTransaction(transaction: editedTransaction, uneditedTransaction: uneditedTransaction, walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM)
        
        XCTAssertTrue(db.transactions.contains(editedTransaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 - 500)
        XCTAssertEqual(db.budgets[0].spentAmount, 0)
//        XCTAssertEqual(db.budgets[0].history[0].spentAmount, 500)
        
        XCTAssertEqual(db.budgets[0].history.count, 1)
    }
    
    func test_update_budget_previous_to_current_range() async throws {
        let uneditedTransaction = Transaction(category: "61B92A61-588E-4C9F-A63D-74AB6F4D7A4F", amount: 1000, originWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", destinationWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE")
        
        await vm.addTransactions(transactions: [uneditedTransaction], walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM, recurringVM: recurringVM)
        
        XCTAssertTrue(db.transactions.contains(uneditedTransaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 - 1000)
        XCTAssertEqual(db.budgets[0].spentAmount, 1000)
        
        let nextBudget = db.budgets[0].nextPeriod
        await budgetVM.updateBudget(budget: nextBudget)
        
        var editedTransaction: Transaction {
            var transaction = db.transactions.first(where: {$0 == uneditedTransaction})!
            transaction.amount = 500
            transaction.category = "A6F32E6E-26B7-4A9E-B7B5-E4C85B2812F5"
            transaction.date = Calendar.current.date(byAdding: .month, value: 1, to: Date())!
            return transaction
        }
        
        await vm.updateTransaction(transaction: editedTransaction, uneditedTransaction: uneditedTransaction, walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM)
        
        XCTAssertTrue(db.transactions.contains(editedTransaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 - 500)
//        XCTAssertEqual(db.budgets[0].spentAmount, 500)
//        XCTAssertEqual(db.budgets[0].history[0].spentAmount, 0)
        
        XCTAssertEqual(db.budgets[0].history.count, 1)
    }
    
    func test_update_budget_previous_to_future_range() async throws {
        let uneditedTransaction = Transaction(category: "61B92A61-588E-4C9F-A63D-74AB6F4D7A4F", amount: 1000, originWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE", destinationWallet: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE")
        
        await vm.addTransactions(transactions: [uneditedTransaction], walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM, recurringVM: recurringVM)
        
        XCTAssertTrue(db.transactions.contains(uneditedTransaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 - 1000)
        XCTAssertEqual(db.budgets[0].spentAmount, 1000)
        
        let nextBudget = db.budgets[0].nextPeriod
        await budgetVM.updateBudget(budget: nextBudget)
        
        var editedTransaction: Transaction {
            var transaction = db.transactions.first(where: {$0 == uneditedTransaction})!
            transaction.amount = 500
            transaction.category = "A6F32E6E-26B7-4A9E-B7B5-E4C85B2812F5"
            transaction.date = Calendar.current.date(byAdding: .month, value: 2, to: Date())!
            return transaction
        }
        
        await vm.updateTransaction(transaction: editedTransaction, uneditedTransaction: uneditedTransaction, walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM)
        
        XCTAssertTrue(db.transactions.contains(editedTransaction))
        
        XCTAssertEqual(db.wallets[0].amount, 0 - 500)
        XCTAssertEqual(db.budgets[0].spentAmount, 0)
//        XCTAssertEqual(db.budgets[0].history[0].spentAmount, 0)
        
        XCTAssertEqual(db.budgets[0].history.count, 1)
    }
}
