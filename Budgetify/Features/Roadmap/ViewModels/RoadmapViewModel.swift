//
//  RoadmapViewModel.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 16/04/23.
//

import Foundation

@MainActor
class RoadmapViewModel: ObservableObject {
    @Published private(set) var features: [RoadmapFeature] = []
    
    @Published private(set) var loading = false
    
    @Published public var selectedStatus: FeatureStatus = .suggested
    @Published public var isSheetVisible = false
    
    private let service: RoadmapServiceProtocol
    
    init(service: RoadmapServiceProtocol) {
        self.service = service
        
        Task {
            await getFeatures()
        }
    }
    
    func getFeatures() async {
        loading = true
        
        do {
            let features = try await service.getRoadmapFeatures()
            
            self.features = features
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
        
        loading = false
    }
    
    func createFeature(feature: RoadmapFeature) async {
        do {
            try await service.createRoadmapFeature(feature: feature)
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
    }
    
    func addVote(feature: RoadmapFeature, userId: String) async {
        do {
            var mutableFeature = feature
            
            guard !userId.isEmpty else { return }
            
            mutableFeature.votes.append(userId)
            
            try await service.updateRoadmapFeature(feature: mutableFeature)
            
            if let index = features.firstIndex(where: { $0.id == feature.id }) {
                features[index] = mutableFeature
            }
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
    }
    
    func removeVote(feature: RoadmapFeature, userId: String) async {
        do {
            var mutableFeature = feature
            
            guard !userId.isEmpty else { return }
            
            mutableFeature.votes.removeAll(where: { $0 == userId })
            
            try await service.updateRoadmapFeature(feature: mutableFeature)
            
            if let index = features.firstIndex(where: { $0.id == feature.id }) {
                features[index] = mutableFeature
            }
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
    }
    
    func addComment(feature: RoadmapFeature, comment: Comment) async {
        do {
            var mutableFeature = feature
            
            mutableFeature.comments.append(comment)
            
            try await service.updateRoadmapFeature(feature: mutableFeature)
            
            if let index = features.firstIndex(where: { $0.id == feature.id }) {
                features[index] = mutableFeature
            }
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
    }
    
    func updateFeature(feature: RoadmapFeature) async {
        do {
            try await service.updateRoadmapFeature(feature: feature)
            
            if let index = features.firstIndex(where: { $0.id == feature.id }) {
                features[index] = feature
            }
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
    }
}
