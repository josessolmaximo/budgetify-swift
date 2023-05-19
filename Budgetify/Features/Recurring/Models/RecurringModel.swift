//
//  RecurringModel.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 16/11/22.
//

import Foundation
import OrderedCollections
import FirebaseFirestore

struct Recurring: Codable {
    var type: RecurringType
    var date: Date
    var amount: Int
    var repeated: Int = 0
    var customType: CustomType
    var weekdays: [String] = []
    var lastOccured: Date = Date()
    
    var dictionary: [String: Any] {
        return [
            "type": type.rawValue,
            "date": date,
            "amount": amount,
            "repeated": repeated,
            "customType": customType.rawValue,
            "weekdays": weekdays,
            "lastOccured": lastOccured
        ]
    }
    
    init(type: RecurringType,
         date: Date,
         amount: Int,
         repeated: Int = 0,
         customType: CustomType,
         weekdays: [String] = [],
         lastOccured: Date = Date()
    ) {
        self.type = type
        self.date = date
        self.amount = amount
        self.repeated = repeated
        self.customType = customType
        self.weekdays = weekdays
        self.lastOccured = lastOccured
    }
    
    init?(dict: [String: Any]){
        guard let type = dict["type"] as? String,
              let date = dict["date"] as? Timestamp,
              let amount = dict["amount"] as? Int,
              let repeated = dict["repeated"] as? Int,
              let customType = dict["customType"] as? String,
              let weekdays = dict["weekdays"] as? [String],
              let lastOccured = dict["lastOccured"] as? Timestamp
        else {
            return nil
        }
        self.type = RecurringType(rawValue: type)!
        self.date = date.dateValue()
        self.amount = amount
        self.repeated = repeated
        self.customType = CustomType(rawValue: customType)!
        self.weekdays = weekdays
        self.lastOccured = lastOccured.dateValue()
    }
}

enum RecurringType: String, Codable, CaseIterable {
    case none = "None"
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case days = "Selected Days"
    case custom = "Custom"
}

enum CustomType: String, Codable {
    case first = "first"
    case last = "last"
}

let defaultRecurring = Recurring(type: .none, date: Date(), amount: 1, customType: .first)

let daysOfTheWeek: OrderedDictionary<String, Int> = ["Sunday": 1, "Monday": 2, "Tuesday": 3, "Wednesday": 4, "Thursday": 5, "Friday": 6, "Saturday": 7]
