//
//  WalletViewModel.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 07/10/22.
//

import SwiftUI
import FirebaseCrashlytics
import FirebaseAuth

@MainActor
class WalletViewModel: ObservableObject {
    @AppStorage("selectedUserId", store: .grouped) var selectedUserId: String = ""
    
    @Published var wallets: [Wallet] = []
    
    @Published var isSheetShown = false
    @Published var isErrorAlertShown = false
    
    @Published var loading = false
    
    let walletService: WalletServiceProtocol
    
    init(walletService: WalletServiceProtocol){
        self.walletService = walletService
        
        guard !selectedUserId.isEmpty else { return }
        
        Task {
            await getWallets()
        }
    }
    
    func getWallets() async {
        loading = true
        
        ErrorManager.shared.logRequest(vm: self)
        
        do {
            self.wallets = try await walletService.getWallets()
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
        
        loading = false
    }
    
    func getWalletById(id: String) -> Wallet? {
        if let wallet = wallets.first(where: {$0.id.uuidString == id }){
            return wallet
        } else if let wallet = defaultWallets.first(where: {$0.id.uuidString == id}){
            return wallet
        } else {
            return nil
        }
    }
    
    func toggleSheet(){
        isSheetShown.toggle()
    }
}
