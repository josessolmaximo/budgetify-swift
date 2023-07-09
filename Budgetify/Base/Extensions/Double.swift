//
//  Double.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 15/12/22.
//

import Foundation

extension Double {
    var toString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        
        return formatter.string(from: self as NSNumber) ?? "0"
    }
}

extension Double {
//    var abbreviated: String {
//        let thousand = self / 1000
//        let million = self / 1000000
//        let billion = self / 1000000000
//        let trillion = self / 1000000000000
//
//        let formatter = NumberFormatter()
//        formatter.maximumFractionDigits = 1
//
//        if trillion >= 1.0 {
//            return "\(formatter.string(from: trillion as NSNumber) ?? "0")T"
//        } else if billion >= 1.0 {
//            return "\(formatter.string(from: billion as NSNumber) ?? "0")B"
//        } else if million >= 1.0 {
//            return "\(formatter.string(from: million as NSNumber) ?? "0")M"
//        } else if thousand >= 1.0 {
//            return "\(formatter.string(from: thousand as NSNumber) ?? "0")K"
//        } else {
//            formatter.maximumFractionDigits = 2
//            return formatter.string(from: self as NSNumber) ?? "0"
//        }
//    }
    
    var abbreviated: String {
        let absoluteValue = abs(self)
        let thousand = absoluteValue / 1000
        let million = absoluteValue / 1000000
        let billion = absoluteValue / 1000000000
        let trillion = absoluteValue / 1000000000000
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        
        if trillion >= 1.0 {
            return "\(self < 0 ? "-" : "")\(formatter.string(from: trillion as NSNumber) ?? "0")T"
        } else if billion >= 1.0 {
            return "\(self < 0 ? "-" : "")\(formatter.string(from: billion as NSNumber) ?? "0")B"
        } else if million >= 1.0 {
            return "\(self < 0 ? "-" : "")\(formatter.string(from: million as NSNumber) ?? "0")M"
        } else if thousand >= 1.0 {
            return "\(self < 0 ? "-" : "")\(formatter.string(from: thousand as NSNumber) ?? "0")K"
        } else {
            formatter.maximumFractionDigits = 2
            return "\(self < 0 ? "-" : "")\(formatter.string(from: absoluteValue as NSNumber) ?? "0")"
        }
    }
}
