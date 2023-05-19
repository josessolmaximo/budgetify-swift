//
//  SharingViewModel.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 27/12/22.
//

import SwiftUI

@MainActor
class SharingViewModel: ObservableObject {
    @AppStorage("email", store: .grouped) var email: String = ""
    @AppStorage("userId", store: .grouped) var userId: String = ""
    
    @Published var invites: [SharingInvite] = []
    @Published var shared: [SharingAccess] = []
    @Published var access: [SharingAccess] = []
    
    @Published var selectedAccess: SharingAccess?
    
    @Published var recipientEmail = ""
    
    @Published var isPopoverShown = false
    
    @Published var isEmailSheetShown = false
    
    @Published var sharingLoading = false
    @Published var invitesLoading = false
    @Published var emailLoading = false
    
    let sharingService: SharingServiceProtocol
    
    init(sharingService: SharingServiceProtocol){
        self.sharingService = sharingService
        
        if !userId.isEmpty {
            Task {
                await getData()
            }
        }
    }
    
    func getData() async {
        await getInvites()
        await getSharing()
        await getAccess()
    }
    
    func getSharing() async {
        sharingLoading = true
        
        ErrorManager.shared.logRequest(vm: self)
        
        do {
            shared = try await sharingService.getSharing()
            
            AnalyticService.updateUserProperty(.sharing, value: shared.map({ $0.recipientUser.id }))
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
        
        sharingLoading = false
    }
    
    func getInvites() async {
        invitesLoading = true
        
        ErrorManager.shared.logRequest(vm: self)
        
        do {
            invites = try await sharingService.checkInvites()
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
        
        invitesLoading = false
    }
    
    func getAccess() async {
        ErrorManager.shared.logRequest(vm: self)
        
        do {
            access = try await sharingService.getAccess()
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
    }
    
    func updateInvite(invite: SharingInvite, action: InviteStatus) async {
        var updatedInvite = invite
        updatedInvite.status = action
        
        invitesLoading = true
        
        ErrorManager.shared.logRequest(vm: self)
        
        do {
            try await sharingService.updateInvite(invite: updatedInvite)
            
            if let index = invites.firstIndex(where: {$0.id == invite.id}){
                invites.remove(at: index)
            }
            
            if action == .accepted {
                ErrorManager.shared.logMessage(message: AlertMessage.acceptedInvite)
            }
            
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
        
        invitesLoading = false
    }
}

