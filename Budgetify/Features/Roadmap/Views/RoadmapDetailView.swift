//
//  RoadmapDetailView.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 16/04/23.
//

import SwiftUI
import CachedAsyncImage

struct RoadmapDetailView: View {
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("userId", store: .grouped) var userId: String = ""
    @AppStorage("email", store: .grouped) var email: String = ""
    @AppStorage("name", store: .grouped) var name: String = ""
    @AppStorage("photoURL", store: .grouped) var photoURL: URL?
    
    @EnvironmentObject var roadmapVM: RoadmapViewModel
    @EnvironmentObject var tm: ThemeManager
    
    @StateObject var vm = RoadmapDetailViewModel()
    
    let feature: RoadmapFeature
    
    var body: some View {
        ZStack {
            tm.selectedTheme.backgroundColor
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    HStack {
                        let color = feature.status == .suggested ? tm.selectedTheme.tertiaryLabel :
                        feature.status == .inProgress ? tm.selectedTheme.tintColor :
                            .green
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text(feature.title)
                                .font(.system(size: 21, weight: .semibold))
                                .lineLimit(2)
                            
                            Text(feature.description)
                                .lineLimit(3)
                            
                            Spacer()
                                .frame(height: 0)
                            
                            HStack {
                                let hasVoted = feature.votes.contains(userId)
                                
                                Button {
                                    Task {
                                        if hasVoted {
                                            await roadmapVM.removeVote(feature: feature, userId: userId)
                                        } else {
                                            await roadmapVM.addVote(feature: feature, userId: userId)
                                        }
                                    }
                                } label: {
                                    Image(systemName: "triangle.fill")
                                        .foregroundColor(hasVoted ? tm.selectedTheme.tintColor : tm.selectedTheme.primaryColor)
                                }
                                
                                Text("\(feature.votes.count)")
                                
                                Spacer()
                                
                                if feature.isBug {
                                    Text("Bug")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(5)
                                        .padding(.horizontal, 5)
                                        .background(
                                            RoundedRectangle(cornerRadius: 5)
                                                .foregroundColor(.red)
                                        )
                                }
                                
                                Text(feature.status.rawValue)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(5)
                                    .padding(.horizontal, 5)
                                    .background(
                                        RoundedRectangle(cornerRadius: 5)
                                            .foregroundColor(color)
                                    )
                            }
                            .font(.system(size: 15, weight: .medium))
                        }
                        
                        Spacer()
                    }
                    
                    HStack {
                        Text("Comments (\(feature.comments.count))")
                            .fontWeight(.semibold)
                        
                        Spacer()
                    }
                    
                    ForEach(feature.comments.sorted(by: { comment1, comment2 in
                        if comment1.votes.count != comment2.votes.count {
                            return comment1.votes.count > comment2.votes.count
                        } else {
                            return comment1.timestamp < comment2.timestamp
                        }
                    })) { comment in
                        commentRow(comment: comment)
                    }
                    
                    HStack(alignment: .top) {
                        ZStack(alignment: .leading) {
                            TextEditor(text: $vm.text)
                                .padding(.leading, 5)
                            
                            HStack {
                                Text("Add a comment")
                                    .foregroundColor(tm.selectedTheme.tertiaryLabel)
                            }
                            .padding(.leading, 9)
                            .opacity(vm.text.isEmpty ? 1 : 0)
                            .allowsHitTesting(false)
                            
                            HStack {
                                Text(vm.text)
                            }
                            .opacity(0)
                            .padding(6)
                            .padding(.leading, 4)
                        }
                        .frame(minHeight: 36)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(tm.selectedTheme.secondaryColor)
                        )
                        
                        Button {
                            Task {
                                await vm.addComment(feature: feature, roadmapVM: roadmapVM)
                            }
                        } label: {
                            Image(systemName: "paperplane")
                                .font(.system(size: 23))
                        }
                        .padding(.top, 5)
                        .foregroundColor(tm.selectedTheme.primaryColor)
                    }
                    .frame(minHeight: 38)
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Feature")
        .modifier(CustomBackButtonModifier(dismiss: dismiss))
        .analyticsScreen(name: self.pageTitle, class: self.pageTitle)
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                KeyboardToolbar()
            }
        }
    }
}

struct RoadmapDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RoadmapDetailView(feature: mockRoadmapFeatures[0])
            .withPreviewEnvironmentObjects()
    }
}

extension RoadmapDetailView {
    func commentRow(comment: Comment) -> some View {
        HStack(alignment: .top) {
            ProfilePictureView(photoURL: URL(string: comment.user.photoURL), dimensions: 30)
                .padding(.top, 5)
                .padding(.trailing, 5)
            
            VStack(alignment: .leading) {
                HStack {
                    Text(comment.user.displayName.isEmpty ? "Anonymous User" : comment.user.displayName)
                        .fontWeight(.semibold)
                    
                    if comment.isAdmin {
                        Text("Admin")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 3)
                            .background(
                                RoundedRectangle(cornerRadius: 3)
                                    .foregroundColor(.black)
                                    .padding(-2.5)
                            )
                            .padding(.leading, 5)
                    }
                    
                    if comment.isMerged {
                        Text("Merged")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 3)
                            .background(
                                RoundedRectangle(cornerRadius: 3)
                                    .foregroundColor(tm.selectedTheme.tintColor)
                                    .padding(-2.5)
                            )
                            .padding(.leading, 5)
                    }
                }
                
                
                Text(comment.text)
            }
            
            Spacer()
            
            VStack(spacing: 5) {
                let hasUpvoted = comment.votes.contains(userId)
                
                Button {
                    Task {
                        if hasUpvoted {
                            await vm.removeCommentUpvote(feature: feature, comment: comment, roadmapVM: roadmapVM)
                        } else {
                            await vm.addCommentUpvote(feature: feature, comment: comment, roadmapVM: roadmapVM)
                        }
                    }
                } label: {
                    Image(systemName: "triangle.fill")
                        .font(.system(size: 13))
                }
                .foregroundColor(hasUpvoted ? tm.selectedTheme.tintColor : tm.selectedTheme.primaryColor)
                
                Text("\(comment.votes.count)")
                    .font(.system(size: 15, weight: .medium))
            }
        }
    }
}
