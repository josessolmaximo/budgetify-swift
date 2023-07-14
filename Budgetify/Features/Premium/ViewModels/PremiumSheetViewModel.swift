//
//  PremiumSheetViewModel.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 22/01/23.
//

import SwiftUI
import RevenueCat
import Mixpanel

@MainActor
class PremiumSheetViewModel: ObservableObject {
    @Published var offering: Offering?
    
    @Published var activeProducts: [String] = []
    @Published var selected: Package?
    
    @Published var error: RevenueCat.ErrorCode?
    @Published var loading = false
    
    @Published var shouldSheetDismiss = false
    
    init(){
        getOfferings()
    }
    
    func getOfferings(){
        ErrorManager.shared.logRequest(vm: self)
        
        Purchases.shared.getOfferings { offerings, error in
            if let offering = offerings?.current, error == nil {
                self.offering = offering
                
                self.selected = offering.availablePackages.min { package1, package2 in
                    if let price1 = package1.storeProduct.pricePerMonth?.decimalValue,
                       let price2 = package2.storeProduct.pricePerMonth?.decimalValue {
                        return price1 < price2
                    } else {
                        return false
                    }
                }
            }
        }
        
        Purchases.shared.getCustomerInfo { customerInfo, error in
            guard error == nil else {
                return
            }
            
            self.activeProducts = customerInfo?.entitlements.active.map({ (key: String, value: EntitlementInfo) in
                return value.productIdentifier
            }) ?? []
        }
    }
    
    func purchase(lastScreen: String) async {
        guard let selected = selected else { return }
        
        loading = true
        
        ErrorManager.shared.logRequest(vm: self)
        
        do {
            let result = try await Purchases.shared.purchase(package: selected)

            if result.customerInfo.entitlements["premium"]?.isActive ?? false, !result.userCancelled {
                PremiumManager.shared.isPremium = true
            }

            self.shouldSheetDismiss = true
            
            Mixpanel.mainInstance().track(event: "Purchase", properties: [
                "productId": selected.storeProduct.productIdentifier,
                "paywallConfig": ConfigManager.shared.paywallLimits,
                "lastScreen": lastScreen
            ])
        } catch {
            if let error = error as? RevenueCat.ErrorCode {
                self.error = error
            }
        }
        
        loading = false
    }
    
    func restore() async {
        loading = true
        
        ErrorManager.shared.logRequest(vm: self)
        
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            
            if customerInfo.entitlements["premium"]?.isActive ?? false {
                PremiumManager.shared.isPremium = true
            }
            
            self.shouldSheetDismiss = true
        } catch {
            if let error = error as? RevenueCat.ErrorCode {
                self.error = error
            }
        }
        
        loading = false
    }
}
