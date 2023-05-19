//
//  WalletService.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 23/11/22.
//

import SwiftUI
import FirebaseFirestore

protocol WalletServiceProtocol {
    func getWallets() async throws -> [Wallet]
    func updateWallet(wallet: Wallet) async throws
    func updateWalletAmount(id: String, amount: Double) async throws
    
    func createWallet(wallet: Wallet) async throws
    func deleteWallet(wallet: Wallet) async throws
    
}

final class WalletService: WalletServiceProtocol {
    @AppStorage("selectedUserId", store: .grouped) var userId: String = ""
    
    var dbRef: CollectionReference {
        return Firestore.firestore().collection("users").document(userId).collection("wallets")
    }
    
//    init(userId: String) {
//        self.userId = userId
//        self.dbRef = db
//    }
    
    func getWallets() async throws -> [Wallet] {
        do {
            let snapshot = try await dbRef.getDocuments()
            
            var wallets: [Wallet] = []
            
            snapshot.documents.forEach { document in
                if let decodedData = Wallet(dict: document.data()){
                    wallets.append(decodedData)
                }
            }
            
            wallets.sort {
                $0.order < $1.order
            }
            
            return wallets
        } catch {
            throw error.firestoreError
        }
    }
    
    func createWallet(wallet: Wallet) async throws {
        do {
            try await dbRef.document(wallet.id.uuidString).setData(wallet.dictionary)
        } catch {
            throw error.firestoreError
        }
    }
    
    func updateWallet(wallet: Wallet) async throws {
        do {
            try await dbRef.document(wallet.id.uuidString).setData(wallet.dictionary)
        } catch {
            throw error.firestoreError
        }
    }
    
    func updateWalletAmount(id: String, amount: Double) async throws {
        do {
            try await dbRef.document(id).updateData(["amount": FieldValue.increment(amount)])
        } catch {
            throw error.firestoreError
        }
    }
    
    func deleteWallet(wallet: Wallet) async throws {
        do {
            try await dbRef.document(wallet.id.uuidString).delete()
        } catch {
            throw error.firestoreError
        }
    }
}

