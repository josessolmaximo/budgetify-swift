//
//  CategoryValidation.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 28/01/23.
//

import Foundation

struct CategoryValidator {
    static func validate(category: Category) throws {
        guard !category.name.isEmpty else {
            throw ValidationError.category(error: .invalidName)
        }
        
        guard !category.image.isEmpty else {
            throw ValidationError.category(error: .invalidIcon)
        }
        
        guard !category.categoryHeader.isEmpty else {
            throw ValidationError.category(error: .invalidCategory)
        }
    }
}

enum CategoryValidation: LocalizedError {
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
            return "Invalid Category"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .invalidName:
            return "Enter a valid name"
        case .invalidIcon:
            return "Choose a valid icon"
        case .invalidCategory:
            return "Enter a category name"
        }
    }
}
