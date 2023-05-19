//
//  SharingModel.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 25/12/22.
//

import Foundation

struct SharingAccess: Identifiable, Hashable {
    var id: UUID
    var recipientUser: User
    var originUser: User
    var permissions: SharingPermissions
    
    var dictionary: [String: Any] {
        return [
            "id": id,
            "recipientUser": recipientUser.dictionary,
            "originUser": originUser.dictionary,
            "permissions": permissions.dictionary
        ]
    }
    
    static func == (lhs: SharingAccess, rhs: SharingAccess) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(recipientUser.id)
        hasher.combine(originUser.id)
        hasher.combine(permissions)
    }
    
    init(id: UUID = UUID(),
         recipientUser: User,
         originUser: User,
         permissions: SharingPermissions
    ){
        self.id = id
        self.recipientUser = recipientUser
        self.originUser = originUser
        self.permissions = permissions
    }
    
    init?(dict: [String: Any]){
        guard let id = dict["id"] as? String,
              let recipientUser = dict["recipientUser"] as? [String: Any],
              let originUser = dict["originUser"] as? [String: Any],
              let permissions = dict["permissions"] as? [String: Any]
        else {
            return nil
        }
        
        self.id = UUID(uuidString: id)!
        self.recipientUser = User(dict: recipientUser)!
        self.originUser = User(dict: originUser)!
        self.permissions = SharingPermissions(dict: permissions)!
    }
    
    
}

struct SharingInvite: Codable, Identifiable {
    var id = UUID()
    var originEmail: String
    var originId: String
    var recipientId: String
    var status: InviteStatus = .pending
    
    var dictionary: [String: Any] {
        return [
            "id": id.uuidString,
            "originEmail": originEmail,
            "originId": originId,
            "recipientId": recipientId,
            "status": status.rawValue
        ]
    }
    
    init(id: UUID = UUID(),
         originEmail: String,
         originId: String,
         recipientId: String,
         status: InviteStatus
    ){
        self.id = id
        self.originEmail = originEmail
        self.originId = originId
        self.recipientId = recipientId
        self.status = status
    }
    
    init?(dict: [String: Any]){
        guard let id = dict["id"] as? String,
              let originEmail = dict["originEmail"] as? String,
              let originId = dict["originId"] as? String,
              let recipientId = dict["recipientId"] as? String,
              let status = dict["status"] as? String
        else {
            return nil
        }
        self.id = UUID(uuidString: id)!
        self.originEmail = originEmail
        self.originId = originId
        self.recipientId = recipientId
        self.status = InviteStatus(rawValue: status)!
    }
}

enum InviteStatus: String, Codable {
    case pending = "Pending"
    case accepted = "Accepted"
    case denied = "Denied"
}

struct SharingPermissions: Hashable {
    var create: Bool
    var read: Bool
    var update: Bool
    var delete: Bool
    
    var dictionary: [String: Any] {
        return [
            "create": create,
            "read": read,
            "update": update,
            "delete": delete
        ]
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(create)
        hasher.combine(read)
        hasher.combine(update)
        hasher.combine(delete)
    }
    
    init(create: Bool, read: Bool, update: Bool, delete: Bool) {
        self.create = create
        self.read = read
        self.update = update
        self.delete = delete
    }
    
    init?(dict: [String: Any]){
        guard let create = dict["create"] as? Bool,
              let read = dict["read"] as? Bool,
              let update = dict["update"] as? Bool,
              let delete = dict["delete"] as? Bool
        else {
            return nil
        }
        
        self.create = create
        self.read = read
        self.update = update
        self.delete = delete
    }
}

struct User: Codable {
    var id: String
    var email: String
    var displayName: String
    var photoURL: String
    
    var dictionary: [String: Any] {
        return [
            "id": id,
            "email": email,
            "displayName": displayName,
            "photoURL": photoURL,
        ]
    }
    
    init(id: String, email: String, displayName: String, photoURL: String) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
    }
    
    init?(dict: [String: Any]){
        guard let id = dict["id"] as? String,
              let email = dict["email"] as? String,
              let displayName = dict["displayName"] as? String,
              let photoURL = dict["photoURL"] as? String
        else {
            return nil
        }
        
        self.id = id
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
    }
}

enum SharingValidation: LocalizedError {
    case alreadyHasAccess
    case invalidEmail
    
    var errorDescription: String? {
        switch self {
        case .alreadyHasAccess:
            return "This Person Already Has Access"
        case .invalidEmail:
            return "Invalid Email"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .alreadyHasAccess:
            return "Try inviting another person"
        case .invalidEmail:
            return "Please enter a valid email"
        }
    }
}
