//
//  HomeViewModel.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 02/10/22.
//

import SwiftUI

protocol TransactionViewProtocol {
    var shouldTransactionsRefresh: Bool { get set }
}

class HomeViewModel: ObservableObject, TransactionSheetProtocol {
    @AppStorage("userId", store: .grouped) private var userId = ""
    @AppStorage("photoURL", store: .grouped) private var photoURL: URL?
    
    @Published var selectedPage: Page = .transactions
    @Published var isSheetShown = false
    @Published var newTransactions: [Transaction] = []
    
    @Published var isSheetQueued: SheetQueue = .none
    
    @Published var shouldTransactionsRefresh = false
    @Published var isErrorAlertShown = false
    @Published var isOnboardingSheetShown = false
    
    var transactions: [Transaction] = []
    
    enum SheetQueue {
        case none
        case transaction(slot: Int? = nil)
    }
    
    @MainActor
    func resetTransactions(wallets: [Wallet], categoryVM: CategoryViewModel) {
        if let defaultWallet = wallets.first(where: { $0.isDefault })?.id.uuidString {
            newTransactions = [Transaction(category: categoryVM.getDefaultCategory(type: .expense), originWallet: defaultWallet, destinationWallet: defaultWallet, creatorPhoto: photoURL?.absoluteString ?? "", createdBy: userId)]
        } else if let firstWallet = wallets.first?.id.uuidString {
            newTransactions = [Transaction(category: categoryVM.getDefaultCategory(type: .expense), originWallet: firstWallet, destinationWallet: firstWallet, creatorPhoto: photoURL?.absoluteString ?? "", createdBy: userId)]
        }
    }
}
