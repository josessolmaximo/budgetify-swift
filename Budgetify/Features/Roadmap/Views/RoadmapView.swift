//
//  RoadmapView.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 11/04/23.
//

import SwiftUI
import ExpandableText

struct RoadmapView: View {
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("userId", store: .grouped) var userId: String = ""
    
    @EnvironmentObject var tm: ThemeManager
    
    @StateObject var vm: RoadmapViewModel
    
    init(service: RoadmapServiceProtocol) {
        self._vm = StateObject(wrappedValue: RoadmapViewModel(service: service))
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                tm.selectedTheme.backgroundColor
                    .ignoresSafeArea()
                
                VStack {
                    tabs
                    
                    ScrollView(showsIndicators: false) {
                        LazyVStack {
                            Spacer()
                                .frame(height: 10)
                            
                            ForEach(vm.features.filter({ $0.status == vm.selectedStatus })) { feature in
                                NavigationLink {
                                    RoadmapDetailView(feature: feature)
                                        .environmentObject(vm)
                                } label: {
                                    featureRow(feature: feature)
                                }
                                .foregroundColor(tm.selectedTheme.primaryLabel)
                            }
                        }
                    }
                    .redacted(reason: vm.loading ? .placeholder : [])
                    .refreshable {
                        Task {
                            await vm.getFeatures()
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Roadmap")
        .navigationBarTitleDisplayMode(.inline)
        .modifier(CustomBackButtonModifier(dismiss: dismiss))
        .analyticsScreen(name: self.pageTitle, class: self.pageTitle)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    vm.isSheetVisible.toggle()
                } label: {
                    Label("Request", systemImage: "plus")
                }
                .foregroundColor(tm.selectedTheme.primaryColor)
            }
        }
        .sheet(isPresented: $vm.isSheetVisible) {
            RoadmapSheetView()
        }
        .environmentObject(vm)
    }
}

struct RoadmapView_Previews: PreviewProvider {
    static var previews: some View {
        RoadmapView(service: MockRoadmapService())
            .withPreviewEnvironmentObjects()
    }
}

extension RoadmapView {
    var tabs: some View {
        HStack {
            ForEach(FeatureStatus.allCases, id: \.self){ status in
                VStack(spacing: 2) {
                    Text(status.rawValue)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(vm.selectedStatus == status ? tm.selectedTheme.primaryLabel : tm.selectedTheme.tertiaryLabel)
                        .background(
                            Rectangle()
                                .frame(height: 2.5)
                                .foregroundColor(tm.selectedTheme.tintColor)
                                .offset(y: 15)
                                .opacity(vm.selectedStatus == status ? 1 : 0)
                        )
                        .onTapGesture {
                            vm.selectedStatus = status
                        }
                }
                
                if status != .implemented {
                    Divider()
                        .frame(height: 20)
                        .padding(.horizontal, 5)
                }
            }
            
            Spacer()
        }
        .padding(.top, 10)
    }
    
    func featureRow(feature: RoadmapFeature) -> some View {
        HStack {
            let color = feature.status == .suggested ? tm.selectedTheme.tertiaryLabel :
            feature.status == .inProgress ? tm.selectedTheme.tintColor :
                .green
            
            Rectangle()
                .frame(width: 3)
                .foregroundColor(
                    color
                )
                .padding(.trailing, 5)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(feature.title)
                    .font(.system(size: 21, weight: .semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(feature.description)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                
                Spacer()
                    .frame(height: 0)
                
                HStack {
                    let hasVoted = feature.votes.contains(userId)
                    
                    Button {
                        Task {
                            if hasVoted {
                                await vm.removeVote(feature: feature, userId: userId)
                            } else {
                                await vm.addVote(feature: feature, userId: userId)
                            }
                        }
                    } label: {
                        Image(systemName: "triangle.fill")
                            .foregroundColor(hasVoted ? tm.selectedTheme.tintColor : tm.selectedTheme.primaryColor)
                    }
                    
                    Text("\(feature.votes.count)")
                    
                    Image(systemName: "bubble.left")
                    
                    Text("\(feature.comments.count)")
                    
                    Spacer()
                    
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
            .padding(.trailing, 5)
            
            Spacer()
        }
    }
}
