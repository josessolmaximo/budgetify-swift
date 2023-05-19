//
//  SharingService.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 26/12/22.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFunctions

protocol SharingServiceProtocol {
    func sendInvite(email: String) async throws
    func createInvite(invite: SharingInvite) async throws
    func updateInvite(invite: SharingInvite) async throws
    
    func checkInvites() async throws -> [SharingInvite]
    
    func getSharing() async throws -> [SharingAccess]
    func getAccess() async throws -> [SharingAccess]
    
    func updateSharing(sharing: SharingAccess) async throws
    func deleteSharing(sharing: SharingAccess) async throws
}

class SharingService: SharingServiceProtocol {
    @AppStorage("email", store: .grouped) var email: String?
    @AppStorage("userId", store: .grouped) var userId: String = ""
    
    let dbRef = Firestore.firestore()
    let cfRef = Functions.functions()
    
    func sendInvite(email: String) async throws {
        do {
            let _ = try await cfRef.httpsCallable("sendInvite").call([
                "recipientEmail": email,
                "originEmail": self.email,
                "originId": self.userId,
                "inviteId": UUID().uuidString
            ])
        } catch {
            throw error.firestoreError
        }
    }
    
    func createInvite(invite: SharingInvite) async throws {
        do {
            try await dbRef
                .collection("invites")
                .document(invite.id.uuidString)
                .setData(invite.dictionary)
        } catch {
            throw error.firestoreError
        }
    }
    
    func updateInvite(invite: SharingInvite) async throws {
        do {
            try await dbRef
                .collection("invites")
                .document(invite.id.uuidString)
                .updateData(["status": invite.status.rawValue])
        } catch {
            throw error.firestoreError
        }
    }
    
    func checkInvites() async throws -> [SharingInvite] {
        do {
            let snapshot = try await dbRef
                .collection("invites")
                .whereField("recipientId", isEqualTo: userId)
                .getDocuments()
            
            var invites: [SharingInvite] = []
            
            snapshot.documents.forEach { document in
                guard let decodedData = SharingInvite(dict: document.data()) else {
                    return
                }
                
                invites.append(decodedData)
            }
            
            return invites
        } catch {
            throw error.firestoreError
        }
    }
    
    func getSharing() async throws -> [SharingAccess] {
        do {
            let snapshot = try await dbRef
                .collection("users")
                .document(userId)
                .collection("sharing")
                .getDocuments()
            
            var invites: [SharingAccess] = []
            
            snapshot.documents.forEach { document in
                guard let decodedData = SharingAccess(dict: document.data()) else {
                    return
                }
                
                invites.append(decodedData)
            }
            
            return invites
        } catch {
            throw error.firestoreError
        }
    }
    
    func updateSharing(sharing: SharingAccess) async throws {
        do {
            try await dbRef
                .collection("users").document(userId).collection("sharing").document(sharing.id.uuidString)
                .updateData([
                    "recipientUser.displayName": sharing.recipientUser.displayName,
                    "permissions": sharing.permissions.dictionary
                ])
        } catch {
            throw error.firestoreError
        }
    }
    
    func deleteSharing(sharing: SharingAccess) async throws {
        do {
            try await dbRef
                .collection("users").document(userId).collection("sharing").document(sharing.id.uuidString)
                .delete()
        } catch {
            throw error.firestoreError
        }
    }
    
    func getAccess() async throws -> [SharingAccess] {
        do {
            let snapshot = try await dbRef
                .collectionGroup("sharing")
                .whereField("recipientUser.id", isEqualTo: userId)
                .getDocuments()
            
            var access: [SharingAccess] = []
            
            snapshot.documents.forEach { document in
                guard let decodedData = SharingAccess(dict: document.data()) else {
                    return
                }
                
                access.append(decodedData)
            }
            
            return access
        } catch {
            throw error.firestoreError
        }
    }
}

class MockSharingService: SharingServiceProtocol {
    func createInvite(invite: SharingInvite) async throws {
        
    }
    
    func updateInvite(invite: SharingInvite) async throws {
        
    }
    
    func sendInvite(email: String) async throws {
        
    }
    
    func updateSharing(sharing: SharingAccess) async throws {
        
    }
    
    func checkInvites() async throws -> [SharingInvite] {
        return [
            SharingInvite(originEmail: "josessolmaximo.appreview@gmail.com", originId: "", recipientId: "", status: .pending),
            SharingInvite(originEmail: "josessolmaximo.developer@gmail.com", originId: "", recipientId: "", status: .pending),
            SharingInvite(originEmail: "josessolmaximo@gmail.com", originId: "", recipientId: "", status: .pending)
        ]
    }
    
    func getSharing() async throws -> [SharingAccess] {
        return []
    }
    
    func getAccess() async throws -> [SharingAccess] {
        return []
    }
    
    func deleteSharing(sharing: SharingAccess) async throws {
        
    }
}
