//
//  WidgetDataManager.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 24/04/23.
//

import Foundation
import WidgetKit

class WidgetDataManager {
    static let encoder = JSONEncoder()
    static let decoder = JSONDecoder()
    
    enum Keys: String {
        case transactions = "transactions"
        case categories = "categories"
        case budgets = "budgets"
        case shortcuts = "shortcuts"
    }
    
    static func setTransactions(transactions: [Transaction]){
        if let data = try? encoder.encode(transactions) {
            UserDefaults.grouped.set(data, forKey: Keys.transactions.rawValue)
            
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    static func setCategories(categories: [Category]){
        if let data = try? encoder.encode(categories) {
            UserDefaults.grouped.set(data, forKey: Keys.categories.rawValue)
            
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    static func setBudgets(budgets: [Budget]){
        if let data = try? encoder.encode(budgets) {
            UserDefaults.grouped.set(data, forKey: Keys.budgets.rawValue)
            
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    static func setShortcuts(shortcuts: [Shortcut]){
        if let data = try? encoder.encode(shortcuts) {
            UserDefaults.grouped.set(data, forKey: Keys.shortcuts.rawValue)
            
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    static func getTransactions() -> [Transaction] {
        if let data = UserDefaults.grouped.data(forKey: Keys.transactions.rawValue) {
            let decodedData = try? decoder.decode([Transaction].self, from: data)
            return decodedData ?? []
        } else {
            return []
        }
    }
    
    static func getCategories() -> [Category] {
        if let data = UserDefaults.grouped.data(forKey: Keys.categories.rawValue) {
            let decodedData = try? decoder.decode([Category].self, from: data)
            return decodedData ?? []
        } else {
            return []
        }
    }
    
    static func getBudgets() -> [Budget] {
        if let data = UserDefaults.grouped.data(forKey: Keys.budgets.rawValue) {
            let decodedData = try? decoder.decode([Budget].self, from: data)
            return decodedData ?? []
        } else {
            return []
        }
    }
    
    static func getShortcuts() -> [Shortcut] {
        if let data = UserDefaults.grouped.data(forKey: Keys.shortcuts.rawValue) {
            let decodedData = try? decoder.decode([Shortcut].self, from: data)
            return decodedData ?? []
        } else {
            return []
        }
    }
}
