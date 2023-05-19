//
//  PreviewHelper.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 10/02/23.
//

import SwiftUI

extension View {
    @MainActor func withPreviewEnvironmentObjects() -> some View {
        let transactionService = MockTransactionService()
        let walletService = MockWalletService()
        let budgetService = MockBudgetService()
        let imageService = MockImageService()
        let categoryService = MockCategoryService()
        let recurringService = MockRecurringService()
        let roadmapService = MockRoadmapService()
        let shortcutService = MockShortcutService()
        let themeManager = ThemeManager()
        
        return self
            .environmentObject(TransactionViewModel(transactionService: transactionService, walletService: walletService, budgetService: budgetService, imageService: imageService))
            .environmentObject(WalletViewModel(walletService: walletService))
            .environmentObject(BudgetViewModel(budgetService: budgetService))
            .environmentObject(CategoryViewModel(categoryService: categoryService))
            .environmentObject(RecurringViewModel(recurringService: recurringService))
            .environmentObject(RoadmapViewModel(service: roadmapService))
            .environmentObject(ShortcutViewModel(service: shortcutService))
            .environmentObject(themeManager)
        
    }
}
