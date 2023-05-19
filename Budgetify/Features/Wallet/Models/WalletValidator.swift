//
//  WalletValidator.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 22/12/22.
//

import Foundation

class WalletValidator {
    static func validate(wallet: Wallet) throws {
        guard !wallet.name.isEmpty else {
            throw ValidationError.wallet(error: .invalidName)
        }
    }
}

enum WalletValidation: LocalizedError {
    case invalidName
    
    var errorDescription: String? {
        switch self {
        case .invalidName:
            return "Invalid Name"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .invalidName:
            return "Enter a valid name"
        }
    }
}
