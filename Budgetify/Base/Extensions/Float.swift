//
//  Float.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 26/11/22.
//

import Foundation

extension Float {
    var formatFloat: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: self as NSNumber) ?? "0"
    }
    
    func getBudgetProgress(spentAmount: Float) -> Float {
        guard self != 0 else {
            return 0
        }
        
        return spentAmount/self
    }
}


