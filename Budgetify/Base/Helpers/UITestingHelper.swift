//
//  UITestingHelper.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 24/12/22.
//

import Foundation

struct UITestingHelper {
    static var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("ui-testing")
    }
    
    static var isPremium: Bool {
        ProcessInfo.processInfo.environment["ispremium"] == "1"
    }
}
