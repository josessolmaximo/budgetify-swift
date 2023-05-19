//
//  RoadmapSheetView.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 16/04/23.
//

import SwiftUI

struct RoadmapSheetView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var roadmapVM: RoadmapViewModel
    @EnvironmentObject var tm: ThemeManager
    
    @StateObject var vm = RoadmapSheetViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    TextField("Title", text: $vm.feature.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(vm.feature.title.isEmpty ? tm.selectedTheme.secondaryLabel : tm.selectedTheme.primaryLabel)
                    
                    ZStack {
                        TextEditor(text: $vm.feature.description)
                            .padding(.leading, -5)
                        
                        VStack {
                            HStack {
                                Text("Description")
                                    .foregroundColor(tm.selectedTheme.secondaryLabel)
                                    .opacity(0.5)
                                
                                Spacer()
                            }
                            .offset(x: 0, y: 7.5)
                            
                            Spacer()
                        }
                        .opacity(vm.feature.description.isEmpty ? 1 : 0)
                        .allowsHitTesting(false)
                    }
                    .frame(minHeight: 84)
                    
                    InfoBox(text: "Suggestions will be reviewed and be approved or merged before appearing on the roadmap.")
                }
                .padding(.horizontal)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        if !vm.loading {
                            Button {
                                dismiss()
                            } label: {
                                Text("Cancel")
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if vm.loading {
                            ProgressView()
                                .tint(tm.selectedTheme.tintColor)
                        } else {
                            Button {
                                Task {
                                    await vm.createFeature(roadmapVM: roadmapVM)
                                }
                            } label: {
                                Text("Suggest")
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .keyboard) {
                        KeyboardToolbar()
                    }
                }
                .onChange(of: vm.shouldSheetDismiss) { shouldSheetDismiss in
                    if shouldSheetDismiss {
                        dismiss()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .analyticsScreen(name: self.pageTitle, class: self.pageTitle)
    }
}

struct RoadmapSheetView_Previews: PreviewProvider {
    static var previews: some View {
        RoadmapSheetView()
            .withPreviewEnvironmentObjects()
    }
}
