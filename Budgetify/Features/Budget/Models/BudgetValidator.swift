//
//  BudgetValidator.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 02/12/22.
//

import Foundation

class BudgetValidator {
    static func validate(budget: Budget) throws {
        guard !budget.name.isEmpty else {
            throw ValidationError.budget(error: .invalidName)
        }
        
        guard !budget.image.isEmpty else {
            throw ValidationError.budget(error: .invalidIcon)
        }
        
        guard !budget.categories.isEmpty else {
            throw ValidationError.budget(error: .invalidCategory)
        }
    }
}

enum BudgetValidation: LocalizedError {
    case invalidName
    case invalidIcon
    case invalidCategory
    
    var errorDescription: String? {
        switch self {
        case .invalidName:
            return "Invalid Name"
        case .invalidIcon:
            return "Invalid Icon"
        case .invalidCategory:
            return "Invalid Categories"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .invalidName:
            return "Enter a valid name"
        case .invalidIcon:
            return "Choose a valid icon"
        case .invalidCategory:
            return "Chose at least one valid category"
        }
    }
}
