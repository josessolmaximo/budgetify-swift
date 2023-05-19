//
//  SharingEmailSheetViewModel.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 02/02/23.
//

import SwiftUI

@MainActor
class SharingEmailSheetViewModel: ObservableObject {
    @AppStorage("email", store: .grouped) var email = ""
    
    @Published var recipientEmail: String = ""
    
    @Published var loading = false
    @Published var shouldSheetDismiss = false
    
    func sendInvite(sharingVM: SharingViewModel) async {
        guard !sharingVM.shared.map({ $0.recipientUser.email.lowercased() }).contains(recipientEmail.lowercased()),
              recipientEmail.lowercased() != self.email.lowercased()
        else {
            ErrorManager.shared.logError(error: ValidationError.sharing(error: .alreadyHasAccess), vm: self)
            return
        }
        
        guard !recipientEmail.isEmpty,
              recipientEmail.contains("@")
        else {
            ErrorManager.shared.logError(error: ValidationError.sharing(error: .invalidEmail), vm: self)
            return
        }
        
        loading = true
        
        ErrorManager.shared.logRequest(vm: self)
        
        do {
            try await sharingVM.sharingService.sendInvite(email: recipientEmail)
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
        
        shouldSheetDismiss = true
        loading = false
    }
}
