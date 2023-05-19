//
//  CategoryModel.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 05/12/22.
//

import Foundation
import OrderedCollections

struct Category: Codable, Identifiable, Equatable, Hashable {
    var id = UUID()
    var categoryHeader: String
    var name: String
    var image: String
    var order: Int
    var type: TransactionType
    var color: String
    var isHidden: Bool = false
    var defaultWallet: String = ""
    
    var dictionary: [String: Any] {
        return [
            "id": id.uuidString,
            "categoryHeader": categoryHeader,
            "name": name,
            "image": image,
            "order": order,
            "type": type.rawValue,
            "color": color,
            "isHidden": isHidden,
            "defaultWallet": defaultWallet
        ]
    }
    
    init(id: UUID = UUID(),
         categoryHeader: String,
         name: String,
         image: String,
         order: Int,
         type: TransactionType,
         color: String,
         isHidden: Bool = false,
         defaultWallet: String = ""
    ) {
        self.id = id
        self.categoryHeader = categoryHeader
        self.name = name
        self.image = image
        self.order = order
        self.type = type
        self.color = color
        self.isHidden = isHidden
        self.defaultWallet = defaultWallet
    }
    
    init?(dict: [String: Any]){
        guard let id = dict["id"] as? String,
              let categoryHeader = dict["categoryHeader"] as? String,
              let name = dict["name"] as? String,
              let image = dict["image"] as? String,
              let order = dict["order"] as? Int,
              let type = dict["type"] as? String,
              let color = dict["color"] as? String,
              let isHidden = dict["isHidden"] as? Bool
        else {
            return nil
        }

        self.id = UUID(uuidString: id)!
        self.categoryHeader = categoryHeader
        self.name = name
        self.image = image
        self.order = order
        self.type = TransactionType(rawValue: type)!
        self.color = color
        self.isHidden = isHidden
        self.defaultWallet = dict["defaultWallet"] as? String ?? ""
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

extension Category {
    var nameColorAndId: Category {
        return Category(id: self.id, categoryHeader: "", name: self.name, image: "", order: 0, type: self.type, color: self.color, isHidden: false)
    }
    
    var withoutWallet: Category {
        var mutableCategory = self
        mutableCategory.defaultWallet = ""
        return mutableCategory
    }
}

enum TransactionType: String, Codable, CaseIterable {
    case income = "Income"
    case expense = "Expense"
    case transfer = "Transfer"
}

#if DEBUG
var initialCategories: OrderedDictionary<String, [Category]> = [
    "Entertainment": [
        Category(id: UUID(uuidString: "61B92A61-588E-4C9F-A63D-74AB6F4D7A4F")!, categoryHeader: "Entertainment", name: "Games", image: "gamecontroller", order: 0, type: .expense, color: defaultColors.purple.rawValue),
        Category(id: UUID(uuidString: "B7EEE857-D30B-4364-A577-16C7329F10DB")!, categoryHeader: "Entertainment", name: "Hobby", image: "camera", order: 1, type: .expense, color: defaultColors.purple.rawValue),
        Category(categoryHeader: "Entertainment", name: "Vacation", image: "beach.umbrella", order: 2, type: .expense, color: defaultColors.purple.rawValue),
        Category(categoryHeader: "Entertainment", name: "Cinema", image: "popcorn", order: 3, type: .expense, color: defaultColors.purple.rawValue),
        Category(categoryHeader: "Entertainment", name: "Music", image: "music.note", order: 4, type: .expense, color: defaultColors.purple.rawValue),
        Category(categoryHeader: "Entertainment", name: "Sports", image: "soccerball", order: 5, type: .expense, color: defaultColors.purple.rawValue),
        Category(categoryHeader: "Entertainment", name: "Books", image: "books.vertical", order: 6, type: .expense, color: defaultColors.purple.rawValue),
        Category(categoryHeader: "Entertainment", name: "Gym", image: "dumbbell", order: 7, type: .expense, color: defaultColors.purple.rawValue),
    ],
    "Food & Drinks": [
        Category(id: UUID(uuidString: "35B7E2A2-F499-4F9D-A6B7-BAE0C6A74B6D")!, categoryHeader: "Food & Drinks", name: "Food", image: "fork.knife", order: 0, type: .expense, color: defaultColors.blue.rawValue),
        Category(categoryHeader: "Food & Drinks", name: "Drinks", image: "wineglass", order: 1, type: .expense, color: defaultColors.blue.rawValue),
        Category(categoryHeader: "Food & Drinks", name: "Coffee", image: "cup.and.saucer", order: 2, type: .expense, color: defaultColors.blue.rawValue),
        Category(categoryHeader: "Food & Drinks", name: "Groceries", image: "cart", order: 3, type: .expense, color: defaultColors.blue.rawValue),
        Category(categoryHeader: "Food & Drinks", name: "Restaurant", image: "menucard", order: 4, type: .expense, color: defaultColors.blue.rawValue),
        Category(categoryHeader: "Food & Drinks", name: "Takeout", image: "takeoutbag.and.cup.and.straw", order: 5, type: .expense, color: defaultColors.blue.rawValue),
    ],
    "Utilities": [
        Category(categoryHeader: "Utilities", name: "Electricity", image: "bolt", order: 0, type: .expense, color: defaultColors.orange.rawValue),
        Category(categoryHeader: "Utilities", name: "Internet", image: "wifi", order: 1, type: .expense, color: defaultColors.orange.rawValue),
        Category(categoryHeader: "Utilities", name: "Cable TV", image: "tv", order: 2, type: .expense, color: defaultColors.orange.rawValue),
        Category(categoryHeader: "Utilities", name: "Water", image: "drop", order: 3, type: .expense, color: defaultColors.orange.rawValue),
        Category(categoryHeader: "Utilities", name: "Telephone", image: "phone", order: 4, type: .expense, color: defaultColors.orange.rawValue),
        Category(categoryHeader: "Utilities", name: "Heating", image: "thermometer.high", order: 5, type: .expense, color: defaultColors.orange.rawValue),
        Category(categoryHeader: "Utilities", name: "Cellphone", image: "phone", order: 6, type: .expense, color: defaultColors.orange.rawValue),
        Category(categoryHeader: "Utilities", name: "Garbage", image: "trash", order: 7, type: .expense, color: defaultColors.orange.rawValue),
        Category(categoryHeader: "Utilities", name: "Security", image: "shield", order: 8, type: .expense, color: defaultColors.orange.rawValue),
        Category(categoryHeader: "Utilities", name: "Laundry", image: "washer", order: 9, type: .expense, color: defaultColors.orange.rawValue),
        Category(categoryHeader: "Utilities", name: "Gas", image: "cooktop", order: 10, type: .expense, color: defaultColors.orange.rawValue),
    ],
    "Income": [
        Category(id: UUID(uuidString: "A6F32E6E-26B7-4A9E-B7B5-E4C85B2812F5")!, categoryHeader: "Income", name: "Income", image: "banknote", order: 0, type: .income, color: defaultColors.green.rawValue),
        Category(categoryHeader: "Income", name: "Salary", image: "dollarsign", order: 1, type: .income, color: defaultColors.green.rawValue),
        Category(categoryHeader: "Income", name: "Investment", image: "chart.line.uptrend.xyaxis", order: 2, type: .income, color: defaultColors.green.rawValue),
        Category(categoryHeader: "Income", name: "Business", image: "briefcase", order: 3, type: .income, color: defaultColors.green.rawValue),
        Category(categoryHeader: "Income", name: "Bonus", image: "giftcard", order: 4, type: .income, color: defaultColors.green.rawValue),
    ],
    "Lifestyle": [
        Category(categoryHeader: "Lifestyle", name: "Charity", image: "gift", order: 0, type: .expense, color: defaultColors.red.rawValue),
        Category(categoryHeader: "Lifestyle", name: "Child Care", image: "figure.and.child.holdinghands", order: 1, type: .expense, color: defaultColors.red.rawValue),
        Category(categoryHeader: "Lifestyle", name: "Doctor", image: "stethoscope", order: 3, type: .expense, color: defaultColors.red.rawValue),
        Category(categoryHeader: "Lifestyle", name: "Education", image: "graduationcap", order: 4, type: .expense, color: defaultColors.red.rawValue),
        Category(categoryHeader: "Lifestyle", name: "Pet", image: "pawprint", order: 5, type: .expense, color: defaultColors.red.rawValue),
        Category(categoryHeader: "Lifestyle", name: "Shopping", image: "bag", order: 6, type: .expense, color: defaultColors.red.rawValue),
        Category(categoryHeader: "Lifestyle", name: "Medication", image: "pills", order: 7, type: .expense, color: defaultColors.red.rawValue),
        Category(categoryHeader: "Lifestyle", name: "Fashion", image: "tshirt", order: 8, type: .expense, color: defaultColors.red.rawValue),
        Category(categoryHeader: "Lifestyle", name: "Cosmetics", image: "icon.cosmetics", order: 9, type: .expense, color: defaultColors.red.rawValue),
    ],
    "Transportation": [
        Category(categoryHeader: "Transportation", name: "Flight", image: "airplane.departure", order: 0, type: .expense, color: defaultColors.yellow.rawValue),
        Category(categoryHeader: "Transportation", name: "Public Transport", image: "bus", order: 1, type: .expense, color: defaultColors.yellow.rawValue),
        Category(categoryHeader: "Transportation", name: "Gas", image: "fuelpump", order: 2, type: .expense, color: defaultColors.yellow.rawValue),
        Category(categoryHeader: "Transportation", name: "Parking", image: "parkingsign.circle", order: 3, type: .expense, color: defaultColors.yellow.rawValue),
        Category(categoryHeader: "Transportation", name: "Maintenance", image: "wrench.and.screwdriver", order: 4, type: .expense, color: defaultColors.yellow.rawValue),
        Category(categoryHeader: "Transportation", name: "Taxi", image: "icon.taxi", order: 5, type: .expense, color: defaultColors.yellow.rawValue),
        Category(categoryHeader: "Transportation", name: "Tolls", image: "road.lanes", order: 6, type: .expense, color: defaultColors.yellow.rawValue),
    ],
    "Housing": [
        Category(categoryHeader: "Housing", name: "Rent", image: "house", order: 0, type: .expense, color: defaultColors.brown.rawValue),
        Category(categoryHeader: "Housing", name: "Home Supplies", image: "lightbulb.led", order: 1, type: .expense, color: defaultColors.brown.rawValue),
        Category(categoryHeader: "Housing", name: "Home Maintenance", image: "pipe.and.drop", order: 2, type: .expense, color: defaultColors.brown.rawValue),
    ],
    "Banking": [
        Category(categoryHeader: "Banking", name: "Credit Card", image: "creditcard", order: 0, type: .expense, color: defaultColors.grey.rawValue),
        Category(categoryHeader: "Banking", name: "Bank Fees", image: "building.columns", order: 1, type: .expense, color: defaultColors.grey.rawValue),
        Category(categoryHeader: "Banking", name: "Loan", image: "icon.loan", order: 2, type: .expense, color: defaultColors.grey.rawValue),
        Category(categoryHeader: "Banking", name: "Car Loan", image: "icon.vehicle.loan", order: 3, type: .expense, color: defaultColors.grey.rawValue),
        Category(categoryHeader: "Banking", name: "Home Loan", image: "icon.house.loan", order: 4, type: .expense, color: defaultColors.grey.rawValue),
        Category(categoryHeader: "Banking", name: "Student Loan", image: "icon.student.loan", order: 5, type: .expense, color: defaultColors.grey.rawValue),
    ],
    "Insurance": [
        Category(categoryHeader: "Insurance", name: "Car Insurance", image: "icon.vehicle.insurance", order: 0, type: .expense, color: defaultColors.darkblue.rawValue),
        Category(categoryHeader: "Insurance", name: "Home Insurance", image: "icon.home.insurance", order: 1, type: .expense, color: defaultColors.darkblue.rawValue),
        Category(categoryHeader: "Insurance", name: "Health Insurance", image: "icon.health.insurance", order: 2, type: .expense, color: defaultColors.darkblue.rawValue),
        Category(categoryHeader: "Insurance", name: "Life Insurance", image: "icon.life.insurance", order: 3, type: .expense, color: defaultColors.darkblue.rawValue),
        Category(categoryHeader: "Insurance", name: "Other Insurance", image: "icon.other.insurance", order: 4, type: .expense, color: defaultColors.darkblue.rawValue),
    ],
    "Taxes": [
        Category(categoryHeader: "Taxes", name: "Property Tax", image: "icon.property.tax", order: 0, type: .expense, color: defaultColors.lightblue.rawValue),
        Category(categoryHeader: "Taxes", name: "Income Tax", image: "icon.income.tax", order: 1, type: .expense, color: defaultColors.lightblue.rawValue),
        Category(categoryHeader: "Taxes", name: "Vehicle Tax", image: "icon.vehicle.tax", order: 2, type: .expense, color: defaultColors.lightblue.rawValue),
        Category(categoryHeader: "Taxes", name: "Other Tax", image: "icon.other.tax", order: 3, type: .expense, color: defaultColors.lightblue.rawValue),
    ],
    "Others": [
        Category(categoryHeader: "Others", name: "Unknown", image: "tray", order: 0, type: .expense, color: defaultColors.grey.rawValue),
        Category(categoryHeader: "Others", name: "Miscellaneous", image: "tray", order: 1, type: .expense, color: defaultColors.grey.rawValue),
    ]
]
#else
var initialCategories: OrderedDictionary<String, [Category]> = [
    "Entertainment": [
        Category(categoryHeader: "Entertainment", name: "Games", image: "gamecontroller", order: 0, type: .expense, color: defaultColors.purple.rawValue),
        Category(categoryHeader: "Entertainment", name: "Hobby", image: "camera", order: 1, type: .expense, color: defaultColors.purple.rawValue),
        Category(categoryHeader: "Entertainment", name: "Vacation", image: "beach.umbrella", order: 2, type: .expense, color: defaultColors.purple.rawValue),
        Category(categoryHeader: "Entertainment", name: "Cinema", image: "popcorn", order: 3, type: .expense, color: defaultColors.purple.rawValue),
        Category(categoryHeader: "Entertainment", name: "Music", image: "music.note", order: 4, type: .expense, color: defaultColors.purple.rawValue),
        Category(categoryHeader: "Entertainment", name: "Sports", image: "soccerball", order: 5, type: .expense, color: defaultColors.purple.rawValue),
        Category(categoryHeader: "Entertainment", name: "Books", image: "books.vertical", order: 6, type: .expense, color: defaultColors.purple.rawValue),
        Category(categoryHeader: "Entertainment", name: "Gym", image: "dumbbell", order: 7, type: .expense, color: defaultColors.purple.rawValue),
    ],
    "Food & Drinks": [
        Category(categoryHeader: "Food & Drinks", name: "Food", image: "fork.knife", order: 0, type: .expense, color: defaultColors.blue.rawValue),
        Category(categoryHeader: "Food & Drinks", name: "Drinks", image: "wineglass", order: 1, type: .expense, color: defaultColors.blue.rawValue),
        Category(categoryHeader: "Food & Drinks", name: "Coffee", image: "cup.and.saucer", order: 2, type: .expense, color: defaultColors.blue.rawValue),
        Category(categoryHeader: "Food & Drinks", name: "Groceries", image: "cart", order: 3, type: .expense, color: defaultColors.blue.rawValue),
        Category(categoryHeader: "Food & Drinks", name: "Restaurant", image: "menucard", order: 4, type: .expense, color: defaultColors.blue.rawValue),
        Category(categoryHeader: "Food & Drinks", name: "Takeout", image: "takeoutbag.and.cup.and.straw", order: 5, type: .expense, color: defaultColors.blue.rawValue),
    ],
    "Utilities": [
        Category(categoryHeader: "Utilities", name: "Electricity", image: "bolt", order: 0, type: .expense, color: defaultColors.orange.rawValue),
        Category(categoryHeader: "Utilities", name: "Internet", image: "wifi", order: 1, type: .expense, color: defaultColors.orange.rawValue),
        Category(categoryHeader: "Utilities", name: "Cable TV", image: "tv", order: 2, type: .expense, color: defaultColors.orange.rawValue),
        Category(categoryHeader: "Utilities", name: "Water", image: "drop", order: 3, type: .expense, color: defaultColors.orange.rawValue),
        Category(categoryHeader: "Utilities", name: "Telephone", image: "phone", order: 4, type: .expense, color: defaultColors.orange.rawValue),
        Category(categoryHeader: "Utilities", name: "Heating", image: "thermometer.high", order: 5, type: .expense, color: defaultColors.orange.rawValue),
        Category(categoryHeader: "Utilities", name: "Cellphone", image: "phone", order: 6, type: .expense, color: defaultColors.orange.rawValue),
        Category(categoryHeader: "Utilities", name: "Garbage", image: "trash", order: 7, type: .expense, color: defaultColors.orange.rawValue),
        Category(categoryHeader: "Utilities", name: "Security", image: "shield", order: 8, type: .expense, color: defaultColors.orange.rawValue),
        Category(categoryHeader: "Utilities", name: "Laundry", image: "washer", order: 9, type: .expense, color: defaultColors.orange.rawValue),
        Category(categoryHeader: "Utilities", name: "Gas", image: "cooktop", order: 10, type: .expense, color: defaultColors.orange.rawValue),
    ],
    "Income": [
        Category(categoryHeader: "Income", name: "Income", image: "banknote", order: 0, type: .income, color: defaultColors.green.rawValue),
        Category(categoryHeader: "Income", name: "Salary", image: "dollarsign", order: 1, type: .income, color: defaultColors.green.rawValue),
        Category(categoryHeader: "Income", name: "Investment", image: "chart.line.uptrend.xyaxis", order: 2, type: .income, color: defaultColors.green.rawValue),
        Category(categoryHeader: "Income", name: "Business", image: "briefcase", order: 3, type: .income, color: defaultColors.green.rawValue),
        Category(categoryHeader: "Income", name: "Bonus", image: "giftcard", order: 4, type: .income, color: defaultColors.green.rawValue),
    ],
    "Lifestyle": [
        Category(categoryHeader: "Lifestyle", name: "Charity", image: "gift", order: 0, type: .expense, color: defaultColors.red.rawValue),
        Category(categoryHeader: "Lifestyle", name: "Child Care", image: "figure.and.child.holdinghands", order: 1, type: .expense, color: defaultColors.red.rawValue),
        Category(categoryHeader: "Lifestyle", name: "Doctor", image: "stethoscope", order: 3, type: .expense, color: defaultColors.red.rawValue),
        Category(categoryHeader: "Lifestyle", name: "Education", image: "graduationcap", order: 4, type: .expense, color: defaultColors.red.rawValue),
        Category(categoryHeader: "Lifestyle", name: "Pet", image: "pawprint", order: 5, type: .expense, color: defaultColors.red.rawValue),
        Category(categoryHeader: "Lifestyle", name: "Shopping", image: "bag", order: 6, type: .expense, color: defaultColors.red.rawValue),
        Category(categoryHeader: "Lifestyle", name: "Medication", image: "pills", order: 7, type: .expense, color: defaultColors.red.rawValue),
        Category(categoryHeader: "Lifestyle", name: "Fashion", image: "tshirt", order: 8, type: .expense, color: defaultColors.red.rawValue),
        Category(categoryHeader: "Lifestyle", name: "Cosmetics", image: "icon.cosmetics", order: 9, type: .expense, color: defaultColors.red.rawValue),
    ],
    "Transportation": [
        Category(categoryHeader: "Transportation", name: "Flight", image: "airplane.departure", order: 0, type: .expense, color: defaultColors.yellow.rawValue),
        Category(categoryHeader: "Transportation", name: "Public Transport", image: "bus", order: 1, type: .expense, color: defaultColors.yellow.rawValue),
        Category(categoryHeader: "Transportation", name: "Gas", image: "fuelpump", order: 2, type: .expense, color: defaultColors.yellow.rawValue),
        Category(categoryHeader: "Transportation", name: "Parking", image: "parkingsign.circle", order: 3, type: .expense, color: defaultColors.yellow.rawValue),
        Category(categoryHeader: "Transportation", name: "Maintenance", image: "wrench.and.screwdriver", order: 4, type: .expense, color: defaultColors.yellow.rawValue),
        Category(categoryHeader: "Transportation", name: "Taxi", image: "icon.taxi", order: 5, type: .expense, color: defaultColors.yellow.rawValue),
        Category(categoryHeader: "Transportation", name: "Tolls", image: "road.lanes", order: 6, type: .expense, color: defaultColors.yellow.rawValue),
    ],
    "Housing": [
        Category(categoryHeader: "Housing", name: "Rent", image: "house", order: 0, type: .expense, color: defaultColors.brown.rawValue),
        Category(categoryHeader: "Housing", name: "Home Supplies", image: "lightbulb.led", order: 1, type: .expense, color: defaultColors.brown.rawValue),
        Category(categoryHeader: "Housing", name: "Home Maintenance", image: "pipe.and.drop", order: 2, type: .expense, color: defaultColors.brown.rawValue),
    ],
    "Banking": [
        Category(categoryHeader: "Banking", name: "Credit Card", image: "creditcard", order: 0, type: .expense, color: defaultColors.grey.rawValue),
        Category(categoryHeader: "Banking", name: "Bank Fees", image: "building.columns", order: 1, type: .expense, color: defaultColors.grey.rawValue),
        Category(categoryHeader: "Banking", name: "Loan", image: "icon.loan", order: 2, type: .expense, color: defaultColors.grey.rawValue),
        Category(categoryHeader: "Banking", name: "Car Loan", image: "icon.vehicle.loan", order: 3, type: .expense, color: defaultColors.grey.rawValue),
        Category(categoryHeader: "Banking", name: "Home Loan", image: "icon.house.loan", order: 4, type: .expense, color: defaultColors.grey.rawValue),
        Category(categoryHeader: "Banking", name: "Student Loan", image: "icon.student.loan", order: 5, type: .expense, color: defaultColors.grey.rawValue),
    ],
    "Insurance": [
        Category(categoryHeader: "Insurance", name: "Car Insurance", image: "icon.vehicle.insurance", order: 0, type: .expense, color: defaultColors.darkblue.rawValue),
        Category(categoryHeader: "Insurance", name: "Home Insurance", image: "icon.home.insurance", order: 1, type: .expense, color: defaultColors.darkblue.rawValue),
        Category(categoryHeader: "Insurance", name: "Health Insurance", image: "icon.health.insurance", order: 2, type: .expense, color: defaultColors.darkblue.rawValue),
        Category(categoryHeader: "Insurance", name: "Life Insurance", image: "icon.life.insurance", order: 3, type: .expense, color: defaultColors.darkblue.rawValue),
        Category(categoryHeader: "Insurance", name: "Other Insurance", image: "icon.other.insurance", order: 4, type: .expense, color: defaultColors.darkblue.rawValue),
    ],
    "Taxes": [
        Category(categoryHeader: "Taxes", name: "Property Tax", image: "icon.property.tax", order: 0, type: .expense, color: defaultColors.lightblue.rawValue),
        Category(categoryHeader: "Taxes", name: "Income Tax", image: "icon.income.tax", order: 1, type: .expense, color: defaultColors.lightblue.rawValue),
        Category(categoryHeader: "Taxes", name: "Vehicle Tax", image: "icon.vehicle.tax", order: 2, type: .expense, color: defaultColors.lightblue.rawValue),
        Category(categoryHeader: "Taxes", name: "Other Tax", image: "icon.other.tax", order: 3, type: .expense, color: defaultColors.lightblue.rawValue),
    ],
    "Others": [
        Category(categoryHeader: "Others", name: "Unknown", image: "tray", order: 0, type: .expense, color: defaultColors.grey.rawValue),
        Category(categoryHeader: "Others", name: "Miscellaneous", image: "tray", order: 1, type: .expense, color: defaultColors.grey.rawValue),
    ]
]
#endif

let initialCategory = Category(categoryHeader: "", name: "", image: "", order: 0, type: .expense, color: defaultColors.blue.rawValue)

let headerCategories = ["Income", "Entertainment", "Food & Drinks", "Housing", "Utilities", "Lifestyle", "Transportation", "Banking", "Insurance", "Taxes", "Others"]

var categoryOrder = ["Income", "Food & Drinks", "Entertainment", "Utilities", "Lifestyle", "Housing", "Transportation", "Banking", "Insurance", "Taxes", "Others"]

let transferCategory = Category(categoryHeader: "Transfer", name: "Transfer", image: "arrow.left.arrow.right", order: 0, type: .transfer, color: defaultColors.grey.rawValue)

var defaultCategories: [Category] = initialCategories.values.reduce([], +)
