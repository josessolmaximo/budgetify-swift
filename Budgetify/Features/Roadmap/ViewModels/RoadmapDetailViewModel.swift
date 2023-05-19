//
//  RoadmapDetailViewModel.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 17/04/23.
//

import SwiftUI

class RoadmapDetailViewModel: ObservableObject {
    @AppStorage("userId", store: .grouped) var userId: String = ""
    @AppStorage("email", store: .grouped) var email: String = ""
    @AppStorage("name", store: .grouped) var name: String = ""
    @AppStorage("photoURL", store: .grouped) var photoURL: URL?
    
    @Published private(set) var loading = false
    
    @Published public var text = ""
    
    func addComment(feature: RoadmapFeature, roadmapVM: RoadmapViewModel) async {
        let comment = Comment(user: .init(id: userId, email: email, displayName: name, photoURL: photoURL?.absoluteString ?? ""), text: text)
        
        await roadmapVM.addComment(feature: feature, comment: comment)
        
        if !ErrorManager.shared.isErrorShown {
            text = ""
        }
    }
    
    func addCommentUpvote(feature: RoadmapFeature, comment: Comment, roadmapVM: RoadmapViewModel) async {
        var mutableFeature = feature
        
        if let index = feature.comments.firstIndex(where: { $0.id == comment.id }) {
            mutableFeature.comments[index].votes.append(userId)
        }
        
        await roadmapVM.updateFeature(feature: mutableFeature)
    }
    
    func removeCommentUpvote(feature: RoadmapFeature, comment: Comment, roadmapVM: RoadmapViewModel) async {
        var mutableFeature = feature
        
        if let index = feature.comments.firstIndex(where: { $0.id == comment.id }) {
            mutableFeature.comments[index].votes.removeAll(where: { $0 == userId })
        }
        
        await roadmapVM.updateFeature(feature: mutableFeature)
    }
}
