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
    
    @Published var categoryOrder: [String] = []
    
    let categoryService: CategoryServiceProtocol
    
    init(categoryService: CategoryServiceProtocol){
        self.categoryService = categoryService
        
        guard !selectedUserId.isEmpty else { return }
        
        Task {
            await getCategories()
            await getCategoryOrder()
        }
    }
    
    func getCategories() async {
        loading = true
        
        do {
            let categories = try await categoryService.getCategories()
            
            self.categories = categories
            
            if self.categoryOrder.isEmpty {
                self.categoryOrder = Array(categories.keys)
            }
            
            allCategories = categories.values.reduce([], +)
            
            WidgetDataManager.setCategories(categories: allCategories)
        } catch {
            ErrorManager.shared.logError(error: error, vm: self)
        }
        
        loading = false
    }
    
    func getCategoryOrder() async {
        loading = true
        
        do {
            let categoryOrder = try await categoryService.getCategoryOrder()
            
            if categoryOrder.isEmpty {
                self.categoryOrder = Array(categories.keys)
            } else {
                self.categoryOrder = categoryOrder
            }
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

struct CategoryDropDelegate: DropDelegate {
    let item : String
    
    @Binding var items : [String]
    @Binding var draggedItem : String?

    func performDrop(info: DropInfo) -> Bool {
        return true
    }
    
    let categoryService = CategoryService()

    func dropEntered(info: DropInfo) {
        guard let draggedItem = self.draggedItem else {
            return
        }

        if draggedItem != item,
           let from = items.firstIndex(of: draggedItem),
           let to = items.firstIndex(of: item) {
            withAnimation {
                items.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
            }
            
            Task {
                try await categoryService.updateCategoryOrder(order: items)
            }
        }
    }
}
