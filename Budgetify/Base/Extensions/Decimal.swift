//
//  Decimal.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 10/12/22.
//

import Foundation

extension Decimal {
    var toString: String {
        let formatter = NumberFormatter()
        
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = SettingsManager.shared.decimalPoints
        
        return formatter.string(from: self as NSNumber) ?? "0"
    }
    
    var doubleValue: Double {
        return NSDecimalNumber(decimal: self).doubleValue
    }
    
    var floatValue: Float {
        return Float(NSDecimalNumber(decimal: self).doubleValue)
    }
}
