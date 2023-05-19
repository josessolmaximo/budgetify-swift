//
//  TransactionModel.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 04/10/22.
//

import Foundation
import SwiftUI
import FirebaseFirestore

struct Transaction: Codable, Identifiable, Equatable, Hashable {
    var id = UUID()
    var category: String
    var date: Date
    var note: String
    var amount: Decimal?
    var originWallet: String
    var destinationWallet: String
    var recurring: Recurring = defaultRecurring
    var images: [String] = []
    var imagesData: [Data] = []
    var tags: [String] = []
    var location: Place = Place(coordinate: nil, name: "", address: nil)
    var budgetRefs: [String] = []
    var type: TransactionType = .expense
    var creatorPhoto: String = ""
    var createdBy: String = ""
    
    var dictionary: [String: Any] {
        return [
            "id": id.uuidString,
            "category": category,
            "date": date,
            "note": note,
            "amount": amount ?? 0,
            "originWallet": originWallet,
            "destinationWallet": destinationWallet,
            "recurring": recurring.dictionary,
            "images": images,
//            "imagesData": imagesData,
            "tags": tags,
            "location": location.dictionary,
            "budgetRefs": budgetRefs,
            "type": type.rawValue,
            "creatorPhoto": creatorPhoto,
            "createdBy": createdBy
        ]
    }
    
    init(id: UUID = UUID(),
         category: String,
         date: Date = Date(),
         note: String = "",
         amount: Decimal? = nil,
         originWallet: String,
         destinationWallet: String,
         recurring: Recurring = defaultRecurring,
         images: [String] = [],
//         imagesData: [Data] = [],
         tags: [String] = [],
         location: Place = Place(coordinate: nil, name: "", address: nil),
         budgetRefs: [String] = [],
         type: TransactionType = .expense,
         creatorPhoto: String = "",
         createdBy: String = ""
    ) {
        self.id = id
        self.category = category
        self.date = date
        self.note = note
        self.amount = amount
        self.originWallet = originWallet
        self.destinationWallet = destinationWallet
        self.recurring = recurring
        self.images = images
//        self.imagesData = imagesData
        self.imagesData = []
        self.tags = tags
        self.location = location
        self.budgetRefs = budgetRefs
        self.type = type
        self.creatorPhoto = creatorPhoto
        self.createdBy = createdBy
    }
    
    init?(dict: [String: Any]){
        guard let id = dict["id"] as? String,
              let category = dict["category"] as? String,
              let date = dict["date"] as? Timestamp,
              let note = dict["note"] as? String,
              let amount = dict["amount"] as? Double,
              let originWallet = dict["originWallet"] as? String,
              let destinationWallet = dict["destinationWallet"] as? String,
              let recurring = dict["recurring"] as? [String: Any],
              let images = dict["images"] as? [String],
//              let imagesData = dict["imagesData"] as? [Data],
              let tags = dict["tags"] as? [String],
              let location = dict["location"] as? [String: Any],
              let budgetRefs = dict["budgetRefs"] as? [String],
              let type = dict["type"] as? String
        else {
            return nil
        }
        
        self.id = UUID(uuidString: id)!
        self.category = category
        self.date = date.dateValue()
        self.note = note
        self.amount = NSDecimalNumber(value: amount).decimalValue
        self.originWallet = originWallet
        self.destinationWallet = destinationWallet
        self.recurring = Recurring(dict: recurring)!
        self.images = images
//        self.imagesData = imagesData
        self.tags = tags
        self.location = Place(dict: location)!
        self.budgetRefs = budgetRefs
        self.type = TransactionType(rawValue: type)!
        self.creatorPhoto = dict["creatorPhoto"] as? String ?? ""
        self.createdBy = dict["createdBy"] as? String ?? ""
    }
    
    static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum PeriodChange: Codable {
    case previous
    case next
}

enum FilterType: String, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
    case custom = "Custom"
}

enum TransactionTypeQuery: String, CaseIterable {
    case all = "All"
    case expense = "Expense"
    case income = "Income"
    case transfer = "Transfer"
}

extension Transaction {
    var nextRecurringPeriod: Transaction {
        var mutableTransaction = self
        
        mutableTransaction.recurring.lastOccured = mutableTransaction.date
        
        switch mutableTransaction.recurring.type {
        case .none:
            return self
        case .daily:
            if let nextDate = Calendar.current.date(byAdding: .day, value: mutableTransaction.recurring.amount, to: mutableTransaction.recurring.date)?.startOfDay {
                mutableTransaction.recurring.date = nextDate
            }
        case .weekly:
            if let nextDate = Calendar.current.date(byAdding: .day, value: 7 * mutableTransaction.recurring.amount, to: mutableTransaction.recurring.date)?.startOfDay {
                mutableTransaction.recurring.date = nextDate
            }
        case .monthly:
            if let nextDate = Calendar.current.date(byAdding: .month, value: mutableTransaction.recurring.amount, to: mutableTransaction.recurring.date)?.startOfDay {
                mutableTransaction.recurring.date = nextDate
            }
        case .custom:
            switch mutableTransaction.recurring.customType {
            case .first:
                let components = Calendar.current.dateComponents([.day], from: mutableTransaction.date)
                let hasDatePassed = mutableTransaction.recurring.amount <= components.day!
                
                if let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: mutableTransaction.recurring.date.startOfMonth())?.startOfDay {
                    
                    if let nextDate = Calendar.current.date(bySetting: .day, value: mutableTransaction.recurring.amount, of: hasDatePassed ? nextMonth : mutableTransaction.date){
                        mutableTransaction.recurring.date = nextDate
                    }
                }
            case .last:
                let components = Calendar.current.dateComponents([.day], from: mutableTransaction.date)
                let currentRange = Calendar.current.range(of: .day, in: .month, for: mutableTransaction.date)!
                
                let hasDatePassed = currentRange.count - mutableTransaction.recurring.amount + 1 <= components.day!
                
                if let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: mutableTransaction.recurring.date.startOfMonth())?.startOfDay {
                    let range = Calendar.current.range(of: .day, in: .month, for: hasDatePassed ? nextMonth : mutableTransaction.date)!
                    
                    if let nextDate = Calendar.current.date(bySetting: .day, value: range.count - mutableTransaction.recurring.amount + 1, of: hasDatePassed ? nextMonth : mutableTransaction.date.endOfMonth()){
                        mutableTransaction.recurring.date = nextDate
                    }
                }
                
            }
        case .days:
            let lastDay = Calendar.current.component(.weekday, from: mutableTransaction.recurring.lastOccured.startOfDay)
            var mappedDays = mutableTransaction.recurring.weekdays.map({ return daysOfTheWeek[$0, default: 0] })
            
            mappedDays.sort()
            
            let nextDay = mappedDays.firstIndex(where: { $0 > lastDay }) ?? 0
            
            let dayComponent = DateComponents(weekday: mappedDays[nextDay])
            
            if let nextDate = Calendar.current.nextDate(after: mutableTransaction.recurring.lastOccured.startOfDay, matching: dayComponent, matchingPolicy: .nextTime)?.startOfDay {
                mutableTransaction.recurring.date = nextDate
            }
            
        }
        
        mutableTransaction.recurring.repeated += 1
        
        mutableTransaction.date = mutableTransaction.recurring.date
        
        return mutableTransaction
    }
}

struct TransactionQuery {
    var keyword = ""
    var categories: [Category: Bool] = [:]
    var wallets: [Wallet: Bool] = [:]
    var transactionType: [TransactionType: Bool] = [:]
}
