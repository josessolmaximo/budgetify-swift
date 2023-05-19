//
//  BudgetModel.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 12/11/22.
//

import Foundation
import FirebaseFirestore

struct Budget: Codable, Identifiable, Equatable {
    var id = UUID()
    var name: String = ""
    var image: String = ""
    var categories: [String] = []
    var budgetAmount: Decimal?
    var spentAmount: Decimal = 0
    var carryover: Bool = false
    var carryoverAmount: Decimal = 0
    var period: BudgetPeriod = BudgetPeriod()
    var startDate: Date = Date().startOfDay
    var endDate: Date = Date().endOfDay
    var createdAt: Date = Date()
    var history: [BudgetHistory] = []
    var order: Int = 0
    
    static func == (lhs: Budget, rhs: Budget) -> Bool {
        return lhs.id == rhs.id
    }
    
    var dictionary: [String: Any] {
        return [
            "id": id.uuidString,
            "name": name,
            "image": image,
            "categories": categories,
            "budgetAmount": budgetAmount,
            "spentAmount": spentAmount,
            "carryover": carryover,
            "carryoverAmount": carryoverAmount,
            "period": period.dictionary,
            "startDate": startDate,
            "endDate": endDate,
            "createdAt": createdAt,
            "history": history.map({$0.dictionary}),
            "order": order
        ]
    }
    
    init(
        id: UUID = UUID(),
        name: String = "",
        image: String = "",
        categories: [String] = [],
        budgetAmount: Decimal? = nil,
        spentAmount: Decimal = 0,
        carryover: Bool = false,
        carryoverAmount: Decimal = 0,
        period: BudgetPeriod = BudgetPeriod(),
        startDate: Date = Date().startOfDay,
        endDate: Date = Date().endOfDay,
        createdAt: Date = Date(),
        history: [BudgetHistory] = [],
        order: Int = 0
    ) {
        self.id = id
        self.name = name
        self.image = image
        self.categories = categories
        self.budgetAmount = budgetAmount
        self.spentAmount = spentAmount
        self.carryover = carryover
        self.carryoverAmount = carryoverAmount
        self.period = period
        self.startDate = startDate
        self.endDate = endDate
        self.createdAt = createdAt
        self.history = history
        self.order = order
    }
    
    init?(dict: [String: Any]){
        guard let id = dict["id"] as? String,
              let name = dict["name"] as? String,
              let image = dict["image"] as? String,
              let categories = dict["categories"] as? [String],
              let budgetAmount = dict["budgetAmount"] as? Double,
              let spentAmount = dict["spentAmount"] as? Double,
              let carryover = dict["carryover"] as? Bool,
              let carryoverAmount = dict["carryoverAmount"] as? Double,
              let period = dict["period"] as? [String: Any],
              let startDate = dict["startDate"] as? Timestamp,
              let endDate = dict["endDate"] as? Timestamp,
              let createdAt = dict["createdAt"] as? Timestamp
//              let history = dict["history"] as? [[String: Any]]
        else {
            return nil
        }
        
        self.id = UUID(uuidString: id)!
        self.name = name
        self.image = image
        self.categories = categories
        self.budgetAmount = NSDecimalNumber(value: budgetAmount).decimalValue
        self.spentAmount = NSDecimalNumber(value: spentAmount).decimalValue
        self.carryover = carryover
        self.carryoverAmount = NSDecimalNumber(value: carryoverAmount).decimalValue
        self.period = BudgetPeriod(dict: period)!
        self.startDate = startDate.dateValue()
        self.endDate = endDate.dateValue()
        self.createdAt = createdAt.dateValue()
        self.history = (dict["history"] as? [[String: Any]] ?? []).map({BudgetHistory(dict: $0)!})
        self.order = dict["order"] as? Int ?? 0
    }
}

let defaultBudgetPeriod = BudgetPeriod()

struct BudgetPeriod: Codable, Hashable {
    var type: BudgetPeriodType
    var amount: Int
    var customType: CustomType
    
    var dictionary: [String: Any] {
        return [
            "type": type.rawValue,
            "amount": amount,
            "customType": customType.rawValue,
        ]
    }
    
    init(type: BudgetPeriodType = .monthly,
         amount: Int = 1,
         customType: CustomType = .last
    ) {
        self.type = type
        self.amount = amount
        self.customType = customType
    }
    
    init?(dict: [String: Any]){
        guard let type = dict["type"] as? String,
              let amount = dict["amount"] as? Int,
              let customType = dict["customType"] as? String
        else {
            return nil
        }
        
        self.type = BudgetPeriodType(rawValue: type)!
        self.amount = amount
        self.customType = CustomType(rawValue: customType)!
    }
}

struct BudgetHistory: Codable {
    var id = UUID()
    var startDate: Date
    var endDate: Date
    var budgetAmount: Decimal
    var spentAmount: Decimal
    var carryoverAmount: Decimal
    var categories: [String]
    
    var dictionary: [String: Any] {
        return [
            "id": id.uuidString,
            "startDate": startDate,
            "endDate": endDate,
            "budgetAmount": budgetAmount,
            "spentAmount": spentAmount,
            "carryoverAmount": carryoverAmount,
            "categories": categories
        ]
    }
    
    init(startDate: Date, endDate: Date, budgetAmount: Decimal, spentAmount: Decimal, carryoverAmount: Decimal, categories: [String]) {
        self.startDate = startDate
        self.endDate = endDate
        self.budgetAmount = budgetAmount
        self.spentAmount = spentAmount
        self.carryoverAmount = carryoverAmount
        self.categories = categories
    }
    
    init?(dict: [String: Any]){
        guard let id = dict["id"] as? String,
              let startDate = dict["startDate"] as? Timestamp,
              let endDate = dict["endDate"] as? Timestamp,
              let budgetAmount = dict["budgetAmount"] as? Double,
              let spentAmount = dict["spentAmount"] as? Double,
              let carryoverAmount = dict["carryoverAmount"] as? Double,
              let categories = dict["categories"] as? [String]
        else {
            return nil
        }
        
        self.id = UUID(uuidString: id)!
        self.startDate = startDate.dateValue()
        self.endDate = endDate.dateValue()
        self.budgetAmount = NSDecimalNumber(value: budgetAmount).decimalValue
        self.spentAmount = NSDecimalNumber(value: spentAmount).decimalValue
        self.carryoverAmount = NSDecimalNumber(value: carryoverAmount).decimalValue
        self.categories = categories
    }
}

enum BudgetPeriodType: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case custom = "Custom"
}

let defaultBudgets: [Budget] = [
    Budget(name: "Home", image: "house", categories: ["61B92A61-588E-4C9F-A63D-74AB6F4D7A4F", "A6F32E6E-26B7-4A9E-B7B5-E4C85B2812F5"], budgetAmount: 100000, spentAmount: 17500, period: BudgetPeriod(type: .daily, amount: 1, customType: .first)),
    Budget(name: "Home", image: "house", categories: ["61B92A61-588E-4C9F-A63D-74AB6F4D7A4F"], budgetAmount: 70000, spentAmount: 54000, period: BudgetPeriod(type: .daily, amount: 1, customType: .first)),
    Budget(name: "Home", image: "house", categories: defaultCategories.map({$0.id.uuidString}), budgetAmount: 90000, spentAmount: 114000, period: BudgetPeriod(type: .daily, amount: 1, customType: .first))
]

extension Budget {
    var budgetProgress: Float {
        guard budgetAmount != 0 else {
            return 1
        }
        
        let progress = spentAmount.floatValue / ((budgetAmount?.floatValue ?? 0) + carryoverAmount.floatValue)
        
        return progress >= 0 ? progress : 1
    }
    
    var overbudget: Bool {
        return self.spentAmount.floatValue > (self.budgetAmount?.floatValue ?? 0) + self.carryoverAmount.floatValue
    }
    
    var nextPeriod: Budget {
        var mutableBudget = self
        mutableBudget.startDate = mutableBudget.endDate
        
        switch period.type {
        case .daily:
            if let newDate = Calendar.current.date(byAdding: .day, value: mutableBudget.period.amount, to: mutableBudget.endDate.startOfDay){
                mutableBudget.endDate = newDate.endOfDay
            }
        case .weekly:
            if let newDate = Calendar.current.date(byAdding: .day, value: mutableBudget.period.amount * 7, to: mutableBudget.endDate){
                mutableBudget.endDate = newDate.endOfDay
            }
        case .monthly:
            switch self.period.customType {
            case .first:
                let components = Calendar.current.dateComponents([.day], from: mutableBudget.startDate)
                let hasDatePassed = mutableBudget.period.amount <= components.day!
                
                if let nextMonth = Calendar.current.date(byAdding: .month, value: hasDatePassed ? 1 : 0, to: mutableBudget.endDate.startOfMonth()) {
                    let refDate = hasDatePassed ? nextMonth : mutableBudget.endDate
                    
                    if let nextDate = Calendar.current.date(bySetting: .day, value: mutableBudget.period.amount, of: refDate){
                        if nextDate.endOfDay < Date() {
                            if let nextMonthDate = Calendar.current.date(bySetting: .day, value: mutableBudget.period.amount, of: nextMonth){
                                mutableBudget.endDate = nextMonthDate.endOfDay
                            }
                        } else {
                            mutableBudget.endDate = nextDate.endOfDay
                        }
                    }
                }
            case .last:
                let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: mutableBudget.endDate)!.startOfMonth()
                let range = Calendar.current.range(of: .day, in: .month, for: nextMonth)
                
                if let nextDate = Calendar.current.date(bySetting: .day, value: (range?.count ?? 31) - mutableBudget.period.amount + 1, of: nextMonth){
                    mutableBudget.endDate = nextDate.endOfDay
                }
            }
        case .custom:
            mutableBudget.startDate = mutableBudget.endDate.endOfDay
            
            let startDateNextSecond = Calendar.current.date(byAdding: .second, value: 1, to: mutableBudget.endDate)!
            let components = Calendar.current.dateComponents([.hour], from: self.startDate, to: startDateNextSecond)
            let hourDifference = components.hour ?? 0
            
            let difference = hourDifference / 24
            
            if let newDate = Calendar.current.date(byAdding: .day, value: difference, to: mutableBudget.endDate.startOfDay){
                mutableBudget.endDate = newDate.endOfDay
            }
        }
        
        if startDate != endDate && !range.contains(Date()) {
            mutableBudget.history.append(.init(startDate: startDate, endDate: endDate, budgetAmount: budgetAmount ?? 0, spentAmount: spentAmount, carryoverAmount: carryoverAmount, categories: categories))
            
            if carryover && self.budgetAmount ?? 0 > spentAmount {
                mutableBudget.carryoverAmount += ((budgetAmount ?? 0) - spentAmount)
            }
        }
        
        mutableBudget.spentAmount = 0
        
        return mutableBudget
    }
}

extension Budget {
    var range: ClosedRange<Date> {
        return startDate...endDate
    }
}

extension BudgetHistory {
    var range: ClosedRange<Date> {
        return startDate...endDate
    }
    
    var budgetProgress: Float {
        guard budgetAmount != 0 else {
            return 1
        }
        
        let progress = spentAmount.floatValue / ((budgetAmount.floatValue) + carryoverAmount.floatValue)
        
        return progress >= 0 ? progress : 1
    }
    
    var overbudget: Bool {
        return spentAmount.floatValue > budgetAmount.floatValue + carryoverAmount.floatValue
    }
}
