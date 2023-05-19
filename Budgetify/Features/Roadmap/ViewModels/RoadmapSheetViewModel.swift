//
//  RoadmapSheetViewModel.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 16/04/23.
//

import Foundation

@MainActor
class RoadmapSheetViewModel: ObservableObject {
    @Published var feature: RoadmapFeature = RoadmapFeature(title: "", description: "")
    
    @Published var shouldSheetDismiss = false
    @Published var loading = false
    
    func createFeature(roadmapVM: RoadmapViewModel) async {
        loading = true
        
        await roadmapVM.createFeature(feature: feature)
        
        if !ErrorManager.shared.isErrorShown {
            await roadmapVM.getFeatures()
            
            shouldSheetDismiss = true
        }
        
        loading = false
    }
}
