//
//  ShortcutViewModel.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 27/04/23.
//

import SwiftUI

class ShortcutViewModel: ObservableObject {
    @AppStorage("userId", store: .grouped) var userId: String = ""
    
    @Published private(set) var shortcuts: [Shortcut] = []
    
    @Published public var selectedShortcut: Shortcut?
    
    @Published private(set) var loading = false
    
    let service: ShortcutServiceProtocol
    
    init(service: ShortcutServiceProtocol) {
        self.service = service
        
        guard !userId.isEmpty else { return }
        
        Task {
            await getShortcuts()
        }
    }
    
    @MainActor
    func getShortcuts() async {
        loading = true
        
        do {
            let shortcuts = try await service.getShortcuts()
            Logger.d(shortcuts)
            self.shortcuts = shortcuts
            
            WidgetDataManager.setShortcuts(shortcuts: shortcuts)
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
        
        loading = false
    }
}
