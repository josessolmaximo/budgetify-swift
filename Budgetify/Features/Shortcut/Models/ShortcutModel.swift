//
//  ShortcutModel.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 26/04/23.
//

import Foundation
import FirebaseFirestore

struct Shortcut: Codable, Identifiable {
    var id = UUID()
    var name: String
    var image: String
    var color: String
    var slot: Int = 0
    var transactions: [Transaction]
    var editBeforeAdding: Bool = true
    
    var createdAt = Date()
    
    var dictionary: [String: Any] {
        return [
            "id": id.uuidString,
            "name": name,
            "image": image,
            "color": color,
            "slot": slot,
            "transactions": transactions.map({ $0.dictionary }),
            "editBeforeAdding": editBeforeAdding,
            "createdAt": createdAt,
        ]
    }
}

extension Shortcut {
    static func fromDictionary(_ dict: [String: Any]) -> Shortcut? {
        guard let id = dict["id"] as? String,
              let name = dict["name"] as? String,
              let image = dict["image"] as? String,
              let color = dict["color"] as? String,
              let slot = dict["slot"] as? Int,
              let transactions = dict["transactions"] as? [[String: Any]],
              let editBeforeAdding = dict["editBeforeAdding"] as? Bool,
              let createdAt = dict["createdAt"] as? Timestamp
        else {
            return nil
        }
        
        let shortcut = Shortcut(
            id: UUID(uuidString: id)!,
            name: name,
            image: image,
            color: color,
            slot: slot,
            transactions: transactions.compactMap({ Transaction(dict: $0 )}),
            editBeforeAdding: editBeforeAdding,
            createdAt: createdAt.dateValue())
        
        return shortcut
    }
}
