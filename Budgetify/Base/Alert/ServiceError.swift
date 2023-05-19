//
//  ServiceError.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 13/01/23.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

enum ServiceError: LocalizedError {
    case firestoreError(code: FirestoreErrorCode.Code)
    case authError(code: FirestoreErrorCode.Code)
    case generalError(description: String, recovery: String)
    case favIconError(code: FavIconErrorCode)
    
    public var errorDescription: String? {
        switch self {
        case .firestoreError(let code):
            switch code {
            case .invalidArgument:
                return "Request contained an invalid argument."
            case .alreadyExists:
                return "The item already exists."
            case .unauthenticated:
                return "You are not authenticated."
            case .permissionDenied:
                return "You do not have sufficient permission."
            case .notFound:
                return "The URL does not exist."
            case .OK:
                return "The action is completed successfully."
            case .unavailable:
                return "You are offline"
            default:
                return "An unknown error occurred"
            }
        case .authError(let code):
            switch code {
            case .OK:
                return "An unknown error occured"
            case .invalidArgument:
                return "An unknown error occured"
            case .deadlineExceeded:
                return "An unknown error occured"
            case .notFound:
                return "An unknown error occured"
            case .alreadyExists:
                return "An unknown error occured"
            case .permissionDenied:
                return "An unknown error occured"
            case .aborted:
                return "An unknown error occured"
            case .outOfRange:
                return "An unknown error occured"
            case .unimplemented:
                return "An unknown error occured"
            case .internal:
                return "An unknown error occured"
            case .unavailable:
                return "An unknown error occured"
            case .dataLoss:
                return "An unknown error occured"
            case .unauthenticated:
                return "You are unauthenticated"
            default:
                return "An unknown error occured"
            }
        case .generalError(let description, _):
            return description
        case .favIconError(let code):
            switch code {
            case .invalidURL:
                return "Invalid URL"
            case .dataNotFound:
                return "Icon Data not Found"
            }
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .firestoreError(code: let code):
            switch code {
            case .OK:
                return "Try again later"
            case .invalidArgument:
                return "Try again later"
            case .alreadyExists:
                return "Try again later"
            case .unauthenticated:
                return "Relog to reauthenticate your account"
            case .permissionDenied:
                return "Ask for permission from the owner of this account or relog"
            case .notFound:
                return "Try again later"
            case .unavailable:
                return "Please check your network connection and reload the app"
            default:
                return "Try again later"
            }
        case .authError(let code):
            switch code {
            case .OK:
                return "An unknown error occured"
            case .invalidArgument:
                return "An unknown error occured"
            case .deadlineExceeded:
                return "An unknown error occured"
            case .notFound:
                return "An unknown error occured"
            case .alreadyExists:
                return "An unknown error occured"
            case .permissionDenied:
                return "An unknown error occured"
            case .resourceExhausted:
                return "An unknown error occured"
            case .failedPrecondition:
                return "An unknown error occured"
            case .aborted:
                return "An unknown error occured"
            case .outOfRange:
                return "An unknown error occured"
            case .unimplemented:
                return "An unknown error occured"
            case .internal:
                return "An unknown error occured"
            case .unavailable:
                return "An unknown error occured"
            case .dataLoss:
                return "An unknown error occured"
            case .unauthenticated:
                return "Please re-log and try again"
            default:
                return "An unknown error occured"
            }
        case .generalError(_, let recovery):
            return recovery
        case .favIconError(let code):
            switch code {
            case .invalidURL:
                return "Please enter a valid url, like www.apple.com"
            case .dataNotFound:
                return "Try entering a different URL"
            }
        }
    }
}

extension Error {
    var firestoreError: ServiceError {
        let firestoreError = FirestoreErrorCode(_nsError: self as NSError)
        return .firestoreError(code: firestoreError.code)
    }
    
    var authError: ServiceError {
        let authError = FirestoreErrorCode(_nsError: self as NSError)
        return .authError(code: authError.code)
    }
}
