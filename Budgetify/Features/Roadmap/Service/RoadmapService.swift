//
//  RoadmapService.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 15/04/23.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol RoadmapServiceProtocol {
    func getRoadmapFeatures() async throws -> [RoadmapFeature]
    func createRoadmapFeature(feature: RoadmapFeature) async throws
    func updateRoadmapFeature(feature: RoadmapFeature) async throws
}

struct RoadmapService: RoadmapServiceProtocol {
    @AppStorage("userId", store: .grouped) var userId: String = ""
    @AppStorage("email", store: .grouped) var email: String?
    @AppStorage("name", store: .grouped) var name: String?
    @AppStorage("photoURL", store: .grouped) var photoURL: URL?
    
    let roadmapRef = Firestore.firestore().collection("roadmap")
    
    func getRoadmapFeatures() async throws -> [RoadmapFeature] {
        do {
            let snapshot = try await roadmapRef
                .whereField("isApproved", isEqualTo: true)
                .getDocuments()
            
            let features = snapshot.documents.compactMap({ doc in
                return try? doc.data(as: RoadmapFeature.self)
            })
            
            let sortedFeatures = features.sorted { feature1, feature2 in
                if feature1.votes.count != feature2.votes.count {
                    return feature1.votes.count > feature2.votes.count
                } else {
                    return feature1.createdAt < feature2.createdAt
                }
            }
            
            return sortedFeatures
        } catch {
            throw error.firestoreError
        }
    }
    
    func createRoadmapFeature(feature: RoadmapFeature) async throws {
        do {
            var mutableFeature = feature
            
            mutableFeature.createdBy = User(id: userId, email: email ?? "", displayName: name ?? "", photoURL: photoURL?.absoluteString ?? "")
            
            try await roadmapRef.document(feature.id.uuidString).setData(mutableFeature.dictionary)
        } catch {
            throw error.firestoreError
        }
    }
    
    func updateRoadmapFeature(feature: RoadmapFeature) async throws {
        do {
            try await roadmapRef.document(feature.id.uuidString).setData(feature.dictionary)
        } catch {
            throw error.firestoreError
        }
    }
}

struct MockRoadmapService: RoadmapServiceProtocol {
    func getRoadmapFeatures() async throws -> [RoadmapFeature] {
        return mockRoadmapFeatures
    }
    
    func createRoadmapFeature(feature: RoadmapFeature) async throws {
        
    }
    
    func updateRoadmapFeature(feature: RoadmapFeature) async throws {
        
    }
}

let mockRoadmapFeatures: [RoadmapFeature] = [
    .init(title: "Face/Touch ID Authentication", description: "Add Face and Touch ID authentication to secure the app along with a password system", status: .inProgress, createdBy: .init(id: "", email: "josessolmaximo.developer@gmail.com", displayName: "Joses Solmaximo", photoURL: "https://lh3.googleusercontent.com/a/AEdFTp4hZ2maT4w3ai0Ixi4ObZYQi-hMmyxaMOUgciQ_=s96-c"), comments: [
        .init(user: .init(id: "", email: "", displayName: "Joses Solmaximo", photoURL: "https://lh3.googleusercontent.com/a/AEdFTp4hZ2maT4w3ai0Ixi4ObZYQi-hMmyxaMOUgciQ_=s96-c"), text: "I need this feature too"),
        .init(user: .init(id: "", email: "", displayName: "Admin", photoURL: "https://lh3.googleusercontent.com/a/AEdFTp4hZ2maT4w3ai0Ixi4ObZYQi-hMmyxaMOUgciQ_=s96-c"), text: "Can you provide more details about this feature"),
        .init(user: .init(id: "", email: "", displayName: "Admin", photoURL: ""), text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.", isAdmin: true)
    ]),
    .init(title: "Widgets", description: "Add widgets to show budget amounts, expenses throughout a period, and a quick add transaction widget"),
    .init(title: "In-App Roadmap", description: "Add a page to display current things I'm working on improving and where users can vote on which feature to be prioritized", status: .implemented),
    .init(title: "Remote Config Email", description: "Change support email with remote config"),
    .init(title: "Test", description: "Test"),
    .init(title: "Test 1", description: "")
]
