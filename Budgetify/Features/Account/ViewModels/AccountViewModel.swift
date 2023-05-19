//
//  AccountViewModel.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 21/12/22.
//

import SwiftUI
import MessageUI
import RevenueCat

@MainActor
class AccountViewModel: ObservableObject {
    @AppStorage("userId", store: .grouped) var userId: String?
    @AppStorage("selectedUserId", store: .grouped) var selectedUserId: String?
    
    @Published var accounts: [SharingAccess] = []
    
    @Published var isDeleteAlertShown = false
    @Published var isErrorAlertShown = false
//    @Published var isValidationErrorAlertShown = false
    
    @Published var isDeletingAccount = false
    @Published var isErasingData = false
    
    @Published var isAlertShown = false
    @Published var isErrorDialogShown = false
    
    @Published var isSwitcherLoading = false
    
    let loginService: LoginServiceProtocol
    
    init(loginService: LoginServiceProtocol){
        self.loginService = loginService
    }
    
    func deleteAccount(dismiss: DismissAction) async {
        isDeletingAccount = true
        
        ErrorManager.shared.logRequest(vm: self)
        
        do {
            try await loginService.deleteAccount()
            let _ = try await Purchases.shared.logOut()
            
            dismiss()
            
            try await Task.sleep(nanoseconds: 500_000_000)
            
            userId = nil
            selectedUserId = nil
            
            PremiumManager.shared.isPremium = false
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
        
        isDeletingAccount = false
    }
    
    func signOut(dismiss: DismissAction) async {
        ErrorManager.shared.logRequest(vm: self)
        
        do {
            try await loginService.signOut()

            let _ = try await Purchases.shared.logOut()
            
            dismiss()
            
            try await Task.sleep(nanoseconds: 500_000_000)

            userId = nil
            selectedUserId = nil

            PremiumManager.shared.isPremium = false
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
    }
    
    func eraseData(onSuccess: @escaping () -> Void) async {
        ErrorManager.shared.logRequest(vm: self)
        
        isErasingData = true
        
        do {
            try await loginService.deleteUserData()
            
            ErrorManager.shared.alertMessage = .dataErasureSuccessful
            
            onSuccess()
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
        
        isErasingData = false
    }
}
