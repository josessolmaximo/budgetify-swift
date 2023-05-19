//
//  ShortcutSheetViewModel.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 27/04/23.
//

import Foundation

class ShortcutSheetViewModel: ObservableObject {
    @Published public var shortcut: Shortcut
    
    @Published private(set) var loading = false
    @Published private(set) var shouldSheetDismiss = false
    
    init(shortcut: Shortcut) {
        self.shortcut = shortcut
    }
    
    @MainActor
    func createShortcut(shortcutVM: ShortcutViewModel) async {
        loading = true
        
        do {
            try await shortcutVM.service.createShortcut(shortcut: shortcut)
            
            await shortcutVM.getShortcuts()
            
            shouldSheetDismiss = true
            
            AnalyticService.incrementUserProperty(.shortcuts, value: 1)
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
        
        loading = false
    }
    
    @MainActor
    func updateShortcut(shortcutVM: ShortcutViewModel) async {
        loading = true
        
        do {
            try await shortcutVM.service.updateShortcut(shortcut: shortcut)
            
            await shortcutVM.getShortcuts()
            
            shouldSheetDismiss = true
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
        
        loading = false
    }
    
    @MainActor
    func deleteShortcut(shortcutVM: ShortcutViewModel) async {
        loading = true
        
        do {
            try await shortcutVM.service.deleteShortcut(shortcut: shortcut)
            
            await shortcutVM.getShortcuts()
            
            shouldSheetDismiss = true
            
            AnalyticService.incrementUserProperty(.shortcuts, value: -1)
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
        
        loading = false
    }
}
