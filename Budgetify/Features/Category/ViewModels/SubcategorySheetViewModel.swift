//
//  CategorySheetViewModel.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 29/11/22.
//

import SwiftUI
import OrderedCollections

protocol SubcategorySheetProtocol {
    var categoryService: CategoryServiceProtocol { get }
    func getCategories() async
}

@MainActor
class SubcategorySheetViewModel: ObservableObject {
    @Published var category: Category
    @Published var customCategoryHeader: String = ""
    @Published var customCategoryField = false
    
    @Published var isDeleteAlertShown = false
    
    @Published var isErrorAlertShown = false
    @Published var errorAlertMessage: String? = "An unknown error occured"
    
    @Published var shouldSheetDismiss = false
    
    @Published var loading = false
    
    let parentVM: SubcategorySheetProtocol
    
    init(category: Category, parentVM: SubcategorySheetProtocol){
        self.category = category
        self.parentVM = parentVM
    }
    
    func updateCategory(category: Category) async {
        loading = true
        
        do {
            try CategoryValidator.validate(category: category)
            try await parentVM.categoryService.updateCategory(category: category)
            
            await parentVM.getCategories()
            
            shouldSheetDismiss = true
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
        
        self.loading = false
    }
    
    func createCategory(category: Category) async {
        loading = true
        
        do {
            try CategoryValidator.validate(category: category)
            try await parentVM.categoryService.createCategory(category: category)
            await parentVM.getCategories()
            
            shouldSheetDismiss = true
            
            AnalyticService.incrementUserProperty(.subcategories, value: 1)
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
        
        loading = false
    }
    
    func deleteCategory(category: Category) async {
        loading = true
        
        do {
            try await parentVM.categoryService.deleteCategory(category: category)
            await parentVM.getCategories()
            
            shouldSheetDismiss = true
           
            AnalyticService.incrementUserProperty(.subcategories, value: -1)
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
        
        loading = false
    }
}
