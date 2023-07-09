//
//  RoadmapModel.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 15/04/23.
//

import Foundation

struct RoadmapFeature: Codable, Identifiable {
    var id = UUID()
    var title: String
    var description: String
    var status: FeatureStatus = .suggested
    var createdAt = Date()
    var createdBy: User?
    var votes: [String] = []
    var comments: [Comment] = []
    var isApproved = false
    var isBug = false
    
    var dictionary: [String: Any] {
        return [
            "id": id.uuidString,
            "title": title,
            "description": description,
            "status": status.rawValue,
            "createdAt": createdAt,
            "createdBy": createdBy?.dictionary,
            "votes": votes,
            "comments": comments.map({ $0.dictionary }),
            "isApproved": isApproved,
            "isBug": isBug
        ]
    }
}

struct Comment: Codable, Identifiable {
    var id = UUID()
    var user: User
    var text: String
    var timestamp: Date = Date()
    var votes: [String] = []
    var isAdmin: Bool = false
    var isMerged: Bool = false
    
    var dictionary: [String: Any] {
        return [
            "id": id.uuidString,
            "user": user.dictionary,
            "text": text,
            "timestamp": timestamp,
            "votes": votes,
            "isAdmin": isAdmin,
            "isMerged": isMerged,
        ]
    }
}

enum FeatureStatus: String, CaseIterable, Codable {
    case suggested = "Suggested"
    case inProgress = "In Progress"
    case implemented = "Implemented"
}
