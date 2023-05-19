//
//  UserDefaults.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 18/04/23.
//

import Foundation

extension UserDefaults {
    static let groupName = "group.com.josessolmaximo.Budgetify"
    
    static var grouped: UserDefaults {
        UserDefaults(suiteName: groupName) ?? .standard
    }
}
