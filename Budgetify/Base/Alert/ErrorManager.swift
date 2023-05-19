//
//  ErrorManager.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 13/01/23.
//

import Foundation
import FirebaseCrashlytics

class ErrorManager: ObservableObject {
    @Published var serviceError: ServiceError?
    @Published var validationError: ValidationError?
    @Published var alertMessage: AlertMessage?
    @Published var versionError = false
    @Published var premiumError = false
    
    static let shared = ErrorManager()
    
    private let crashlytics = Crashlytics.crashlytics()
    
    public var isErrorShown: Bool {
        serviceError != nil &&
        validationError != nil &&
        alertMessage != nil &&
        premiumError
    }
    
    func logRequest<C>(functionName: String = #function, vm: C?){
        crashlytics.log("\(String(describing: vm.self)) - \(functionName) - Request")
    }
    
    func logError<C>(error: Error, showAsAlert: Bool = true, functionName: String = #function, vm: C?){
        switch error {
        case let serviceError as ServiceError:
            crashlytics.log("\(String(describing: vm.self)) - \(functionName) - \(serviceError.errorDescription ?? "Unknown Error")")
            
            Logger.e(serviceError.errorDescription ?? "Unknown Error")
            
            guard showAsAlert else { break }
            
            self.serviceError = serviceError
            
        case let validationError as ValidationError:
            guard showAsAlert else { break }
            self.validationError = validationError
        default:
            break
        }
    }
    
    func logMessage(message: Error, showAsAlert: Bool = true){
        switch message {
        case let alertMessage as AlertMessage:
            guard showAsAlert else { break }
            self.alertMessage = alertMessage
        default:
            break
        }
    }
}
