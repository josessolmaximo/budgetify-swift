//
//  CategorySheetViewModel.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 26/01/23.
//

import SwiftUI

@MainActor
class CategorySheetViewModel: ObservableObject {
    @Published var name = ""
    @Published var color = defaultColors.blue.rawValue.stringToColor()
    @Published var categories: [Category] = []
    
    @Published var loading = false
    @Published var shouldSheetDismiss = false
    
    init(name: String, color: Color, categories: [Category]){
        self.name = name
        self.color = color
        self.categories = categories
    }
    
    func updateCategories(categoryVM: CategoryViewModel) async {
//        loading = true
//        
//        let newCategories = categories.map { category in
//            var mutableCategory = category
//            mutableCategory.categoryHeader = name
////            mutableCategory.color = color.cgColor?.components
//        }
//        
//        do {
//            try await categoryVM.categoryService.updateCategories(categories: categories)
//            
//            shouldSheetDismiss = true
//        } catch {
//            ErrorManager.shared.logError(error: error, vm: self)
//        }
//        
//        loading = false
    }
}
