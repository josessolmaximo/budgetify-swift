//
//  WalletSheetViewModel.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 23/11/22.
//

import SwiftUI

@MainActor
class WalletSheetViewModel: ObservableObject {
    @Published var isDeleteAlertShown = false
    @Published var shouldSheetDismiss = false
    
    @Published var isErrorAlertShown = false
    @Published var errorAlertMessage: String = "An unknown error occured"
    
    @Published var serviceError: ServiceError?
    
    @Published var loading = false
    
    @Published var wallet: Wallet
    
    let parentVM: WalletViewModel
    
    init(wallet: Wallet, parentVM: WalletViewModel){
        self.wallet = wallet
        self.parentVM = parentVM
    }
    
    func deleteWallet(wallet: Wallet) async {
        loading = true
        
        ErrorManager.shared.logRequest(vm: self)
        
        do {
            try await parentVM.walletService.deleteWallet(wallet: wallet)
            
            await parentVM.getWallets()
            
            shouldSheetDismiss = true
            
            AnalyticService.incrementUserProperty(.wallets, value: -1)
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
        
        loading = false
    }
    
    func createWallet(wallet: Wallet) async {
        loading = true
        
        ErrorManager.shared.logRequest(vm: self)
        
        do {
            try WalletValidator.validate(wallet: wallet)
            try await parentVM.walletService.createWallet(wallet: wallet)
            
            await parentVM.getWallets()
            
            shouldSheetDismiss = true
            
            AnalyticService.incrementUserProperty(.wallets, value: 1)
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
        
        loading = false
    }
    
    func updateWallet(wallet: Wallet) async {
        loading = true
        
        ErrorManager.shared.logRequest(vm: self)
        
        do {
            try WalletValidator.validate(wallet: wallet)
            try await parentVM.walletService.updateWallet(wallet: wallet)
            
            await parentVM.getWallets()
            
            shouldSheetDismiss = true
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
        
        loading = false
    }
}
