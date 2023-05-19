//
//  PremiumManager.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 13/02/23.
//

import SwiftUI
import RevenueCat

class PremiumManager {
    @AppStorage("userId", store: .grouped) var userId = ""
    @AppStorage("selectedUserId", store: .grouped) var selectedUserId = ""
    
    static let shared = PremiumManager()
    
    public var isPremium = false
    
    init(){
        Task {
            await getPremium(id: selectedUserId)
        }
    }
    
    public func getPremium(id: String) async {
        do {
            let result = try await Purchases.shared.logIn(id)
            
            self.isPremium = result.customerInfo.entitlements["premium"]?.isActive ?? false || UITestingHelper.isPremium
        } catch {
            isPremium = false
            ErrorManager.shared.logError(error: error, vm: self)
        }
    }
    
//    public func getPremiumById(id: String) async -> Bool {
//        do {
//            let result = try await Purchases.shared.logIn(id)
//            let isPremium = result.customerInfo.entitlements["premium"]?.isActive ?? false || UITestingHelper.isPremium
//            
//            self.isPremium = isPremium
//            return isPremium
//        } catch {
//            ErrorManager.shared.logError(error: error, vm: self)
//            isPremium = false
//            return false
//        }
//    }
}
