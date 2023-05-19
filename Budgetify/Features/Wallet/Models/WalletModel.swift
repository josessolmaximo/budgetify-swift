//
//  WalletModel.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 07/10/22.
//

import SwiftUI

struct Wallet: Codable, Identifiable, Hashable {
    var id = UUID()
    var name: String
    var amount: Decimal = 0
    var image: String
    var isExcluded: Bool = false
    var isDefault: Bool = false
    var type: WalletType = .debit
    var targetAmount: Decimal?
    var order: Int = 0
    
    var dictionary: [String: Any] {
        return [
            "id": id.uuidString,
            "name": name,
            "amount": amount,
            "image": image,
            "isExcluded": isExcluded,
            "isDefault": isDefault,
            "type": type.rawValue,
            "targetAmount": targetAmount ?? 0,
            "order": order
        ]
    }
    
    init(id: UUID = UUID(),
         name: String,
         amount: Decimal = 0,
         image: String,
         isExcluded: Bool = false,
         isDefault: Bool = false,
         type: WalletType = .debit,
         targetAmount: Decimal? = nil,
         order: Int = 0
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.image = image
        self.isExcluded = isExcluded
        self.isDefault = isDefault
        self.type = type
        self.targetAmount = targetAmount
        self.order = order
    }
    
    init?(dict: [String: Any]){
        guard let id = dict["id"] as? String,
              let name = dict["name"] as? String,
              let amount = dict["amount"] as? Double,
              let image = dict["image"] as? String,
              let isExcluded = dict["isExcluded"] as? Bool,
              let type = dict["type"] as? String,
              let targetAmount = dict["targetAmount"] as? Double
        else {
            return nil
        }
        
        self.id = UUID(uuidString: id)!
        self.name = name
        self.amount = NSDecimalNumber(value: amount).decimalValue
        self.image = image
        self.isExcluded = isExcluded
        self.isDefault = dict["isDefault"] as? Bool ?? false
        self.type = WalletType(rawValue: type)!
        self.targetAmount = NSDecimalNumber(value: targetAmount).decimalValue
        self.order = dict["order"] as? Int ?? 0
    }
    
    static func == (lhs: Wallet, rhs: Wallet) -> Bool {
        return lhs.id == rhs.id
    }
}

enum WalletType: String, Codable, CaseIterable {
    case debit = "Debit"
    case credit = "Credit"
    case target = "Target"
}

let defaultWallets = [
    Wallet(id: UUID(uuidString: "BB4FA0B4-26C8-473D-9CD8-66DF0C3326AE")!, name: "Cash", amount: 0, image: "custom.wallet"),
    Wallet(id: UUID(uuidString: "16E94948-B52B-4F4C-AA57-051614BAC5F5")!, name: "OVO", amount: 5100.52, image: "logo.ovo"),
    Wallet(name: "Gopay", amount: 11000.53, image: "logo.gopay"),
    Wallet(name: "BCA", amount: 15500.54, image: "logo.bca", type: .target, targetAmount: 20000),
    Wallet(name: "Credit", amount: 108770.5, image: "creditcard", type: .credit),
]
