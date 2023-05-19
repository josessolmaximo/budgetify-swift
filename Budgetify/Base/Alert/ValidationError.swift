//
//  ValidationError.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 14/01/23.
//

import Foundation

enum ValidationError: LocalizedError {
    case sharing(error: SharingValidation)
    case category(error: CategoryValidation)
    case budget(error: BudgetValidation)
    case wallet(error: WalletValidation)
    
    var errorDescription: String? {
        switch self {
        case .sharing(let error):
            return error.errorDescription
        case .category(let error):
            return error.errorDescription
        case .budget(let error):
            return error.errorDescription
        case .wallet(let error):
            return error.errorDescription
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .sharing(let error):
            return error.recoverySuggestion
        case .category(let error):
            return error.recoverySuggestion
        case .budget(let error):
            return error.recoverySuggestion
        case .wallet(let error):
            return error.recoverySuggestion
        }
    }
}
