//
//  AlertMessage.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 16/01/23.
//

import Foundation

enum AlertMessage: LocalizedError {
    case acceptedInvite
    case userPremiumExpired
    case emailAppNotFound
    case dataErasureSuccessful
    
    var errorDescription: String? {
        switch self {
        case .acceptedInvite:
            return "Invite Accepted"
        case .userPremiumExpired:
            return "Premium Expired"
        case .emailAppNotFound:
            return "Failed to open mail app"
        case .dataErasureSuccessful:
            return "Successfully Erased Data"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .acceptedInvite:
            return "It may take up to 10 minutes to complete the process"
        case .userPremiumExpired:
            return "User's Premium is expired, renew to use this feature"
        case .emailAppNotFound:
            return "You don't have any email accounts active on this device"
        case .dataErasureSuccessful:
            return "All your data has been erased, and categories have been reset"
        }
    }
}
