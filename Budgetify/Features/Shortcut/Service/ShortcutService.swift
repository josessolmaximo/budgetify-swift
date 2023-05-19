//
//  ShortcutService.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 26/04/23.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol ShortcutServiceProtocol {
    func getShortcuts() async throws -> [Shortcut]
    func createShortcut(shortcut: Shortcut) async throws
    func updateShortcut(shortcut: Shortcut) async throws
    func deleteShortcut(shortcut: Shortcut) async throws
}

struct ShortcutService: ShortcutServiceProtocol {
    @AppStorage("userId", store: .grouped) var userId: String = ""
    
    var dbRef: CollectionReference {
        return Firestore.firestore().collection("users").document(userId).collection("shortcuts")
    }
    
    func getShortcuts() async throws -> [Shortcut] {
        do {
            let snapshot = try await dbRef.getDocuments()
            
            let shortcuts = snapshot.documents.compactMap { doc in
                return Shortcut.fromDictionary(doc.data())
            }
            
            let sortedShortcuts = shortcuts.sorted {
                if $0.slot != 0 {
                    return false
                } else if $1.slot != 0 {
                    return true
                } else {
                    return $0.slot < $1.slot
                }
            }
            
            return sortedShortcuts
        } catch {
            throw error.firestoreError
        }
    }
    
    func createShortcut(shortcut: Shortcut) async throws {
        do {
            try await dbRef.document(shortcut.id.uuidString).setData(shortcut.dictionary)
        } catch {
            throw error.firestoreError
        }
    }
    
    func updateShortcut(shortcut: Shortcut) async throws {
        do {
            try await dbRef.document(shortcut.id.uuidString).setData(shortcut.dictionary)
        } catch {
            throw error.firestoreError
        }
    }
    
    func deleteShortcut(shortcut: Shortcut) async throws {
        do {
            try await dbRef.document(shortcut.id.uuidString).delete()
        } catch {
            throw error.firestoreError
        }
    }
}

struct MockShortcutService: ShortcutServiceProtocol {
    var shortcuts: [Shortcut] = [
        .init(name: "Parking", image: "parkingsign", color: defaultColors.yellow.rawValue, transactions: [
            .init(category: "", originWallet: "", destinationWallet: ""),
            .init(category: "", originWallet: "", destinationWallet: "")
        ]),
        .init(name: "Coffee", image: "cup.and.saucer", color: defaultColors.blue.rawValue, transactions: [
            .init(category: "", originWallet: "", destinationWallet: ""),
        ]),
        .init(name: "Going Out", image: "popcorn", color: defaultColors.purple.rawValue, transactions: [
            .init(category: "", originWallet: "", destinationWallet: ""),
            .init(category: "", originWallet: "", destinationWallet: ""),
            .init(category: "", originWallet: "", destinationWallet: ""),
            .init(category: "", originWallet: "", destinationWallet: ""),
            .init(category: "", originWallet: "", destinationWallet: ""),
            .init(category: "", originWallet: "", destinationWallet: ""),
        ])
    ]
    
    func getShortcuts() async throws -> [Shortcut] {
        return shortcuts
    }
    
    func createShortcut(shortcut: Shortcut) async throws {
            
    }
    
    func updateShortcut(shortcut: Shortcut) async throws {
    
    }
    
    func deleteShortcut(shortcut: Shortcut) async throws {
        
    }
}
