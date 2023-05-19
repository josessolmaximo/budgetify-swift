//
//  SharingAccessSheetViewModel.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 28/12/22.
//

import Foundation

@MainActor
class SharingAccessSheetViewModel: ObservableObject {
    @Published var sharingAccess: SharingAccess
    
    @Published var shouldSheetDismiss = false
    @Published var loading = false
    
    init(sharingAccess: SharingAccess){
        self.sharingAccess = sharingAccess
    }
    
    func updateSharing(sharingVM: SharingViewModel) async {
        loading = true
        
        ErrorManager.shared.logRequest(vm: self)
        
        do {
            try await sharingVM.sharingService.updateSharing(sharing: sharingAccess)
            await sharingVM.getData()
            
            shouldSheetDismiss = true
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
        
        loading = false
    }
    
    func deleteSharing(sharingVM: SharingViewModel) async {
        loading = true
        
        ErrorManager.shared.logRequest(vm: self)
        
        do {
            try await sharingVM.sharingService.deleteSharing(sharing: sharingAccess)
            await sharingVM.getData()
            
            shouldSheetDismiss = true
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
        
        loading = false
    }
}
