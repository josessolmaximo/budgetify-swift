//
//  AnalyticService.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 30/04/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct AnalyticService {
    static var userId: String = UserDefaults.grouped.string(forKey: "userId") ?? ""
    
    static var dbRef: DocumentReference {
        return Firestore.firestore().collection("users").document(userId)
    }
    
    static func updateUserProperty(_ field: UserProperties.CodingKeys, value: Any) {
        guard !userId.isEmpty else { return }
        
        dbRef
            .updateData([
                "properties.\(field.stringValue)": value
            ])
    }
    
    static func incrementUserProperty(_ field: UserProperties.CodingKeys, value: Int) {
        guard !userId.isEmpty else { return }
        
        dbRef
            .updateData([
                "properties.\(field.stringValue)": FieldValue.increment(Double(value))
            ])
    }
}
