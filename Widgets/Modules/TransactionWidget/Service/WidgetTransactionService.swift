//
//  WidgetTransactionService.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 18/04/23.
//

import SwiftUI
import FirebaseFirestore

struct WidgetTransactionService {
    let userId = UserDefaults(suiteName: "group.com.josessolmaximo.Budgetify")?.string(forKey: "selectedUserId") ?? ""
    
    var dbRef: CollectionReference {
        return Firestore.firestore().collection("users").document(userId).collection("transactions")
    }
    
    func getTransactions(startDate: Date, endDate: Date) async throws -> [Transaction] {
        guard !userId.isEmpty else { return [] }
        
        do {
            let snapshot = try await dbRef
                .whereField("date", isGreaterThanOrEqualTo: startDate)
                .whereField("date", isLessThanOrEqualTo: endDate)
                .order(by: "date", descending: true)
                .getDocuments()
            
            var transactions: [Transaction] = []
            
            snapshot.documents.forEach { document in
                if let decodedData = Transaction(dict: document.data()){
                    transactions.append(decodedData)
                }
            }
            
            transactions.sort {
                $0.date > $1.date
            }
            
            return transactions
        } catch {
            throw error.firestoreError
        }
    }
}
