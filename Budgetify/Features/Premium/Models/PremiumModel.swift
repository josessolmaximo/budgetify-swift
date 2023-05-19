//
//  PremiumModel.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 24/01/23.
//

import Foundation
import RevenueCat

extension SubscriptionPeriod {
    var duration: String {
        switch self.unit {
        case .day:
            return "\(self.value) Day"
        case .week:
            if self.value > 1 {
                return "\(self.value) Week"
            } else {
                return "7 Day"
            }
        case .month:
            return "\(self.value) Month"
        case .year:
            return "\(self.value) Year"
        }
    }
}
