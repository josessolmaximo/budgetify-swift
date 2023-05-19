//
//  CategoryViewModel.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 04/12/22.
//

import SwiftUI
import OrderedCollections

@MainActor
class CategoryViewModel: ObservableObject, SubcategorySheetProtocol {
    @AppStorage("selectedUserId", store: .grouped) var selectedUserId: String = ""
    
    @Published var categories: OrderedDictionary<String, [Category]> = [:]
    @Published var allCategories: [Category] = []
    @Published var isEditCategorySheetShown = false
    @Published var isCreateCategorySheetShown = false
    
    @Published var selectedSubcategory: Category?
    @Published var selectedCategory: String?
    
    @Published var loading = false
    
    let categoryService: CategoryServiceProtocol
    
    init(categoryService: CategoryServiceProtocol){
        self.categoryService = categoryService
        
        guard !selectedUserId.isEmpty else { return }
        
        Task {
            await getCategories()
        }
    }
    
    func getCategories() async {
        loading = true
        
        do {
            let categories = try await categoryService.getCategories()
            
            self.categories = categories
            
            allCategories = categories.values.reduce([], +)
            
            WidgetDataManager.setCategories(categories: allCategories)
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
        
        loading = false
    }
    
    func getDefaultCategory(type: TransactionType) -> String {
        if type == .expense {
            return allCategories.first(where: { !$0.isHidden && $0.type == .expense })?.id.uuidString ?? ""
        } else if type == .income {
            return allCategories.first(where: { !$0.isHidden && $0.type == .income })?.id.uuidString ?? ""
        } else {
            return ""
        }
    }
    
    func getCategoryById(id: String) -> Category? {
        if let category = allCategories.first(where: { $0.id.uuidString == id }){
            return category
        } else if let category = initialCategories.values.reduce([], +).first(where: { $0.id.uuidString == id }) {
            return category
        } else {
            return nil
        }
    }
}
