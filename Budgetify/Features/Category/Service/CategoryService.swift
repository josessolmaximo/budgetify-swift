//
//  CategoryService.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 29/11/22.
//

import SwiftUI
import OrderedCollections
import FirebaseFirestore

protocol CategoryServiceProtocol {
    func getCategories() async throws -> OrderedDictionary<String, [Category]>
    func updateCategory(category: Category) async throws
    func createCategory(category: Category) async throws
    func deleteCategory(category: Category) async throws
    func updateCategories(categories: [Category]) async throws
    
    func getCategoryOrder() async throws -> [String]
    func updateCategoryOrder(order: [String]) async throws
}

class CategoryService: CategoryServiceProtocol {
    @AppStorage("selectedUserId", store: .grouped) var userId: String = ""
    
    var dbRef: CollectionReference {
        return Firestore.firestore().collection("users").document(userId).collection("categories")
    }
    
    var userRef: DocumentReference {
        return Firestore.firestore().collection("users").document(userId)
    }
    
    func getCategoryOrder() async throws -> [String] {
        do {
            let snapshot = try await userRef.getDocument()
            
            if let categoryOrder = snapshot.data()?["categoryOrder"] as? [String] {
                return categoryOrder
            } else {
                return []
            }
        } catch {
            throw error.firestoreError
        }
    }
    
    func updateCategoryOrder(order: [String]) async throws {
        do {
            try await userRef.updateData([
                "categoryOrder": order
            ])
        } catch {
            throw error.firestoreError
        }
    }
    
    func getCategories() async throws -> OrderedDictionary<String, [Category]> {
        do {
            let snapshot = try await dbRef.getDocuments()
            
            var categories: OrderedDictionary<String, [Category]> = [:]
            
            snapshot.documents.forEach { document in
                if let decodedData = Category(dict: document.data()){
                    categories[decodedData.categoryHeader, default: []].append(decodedData)
                }
            }
            
            for (key, value) in categories {
                categories[key] = value.sorted(by: { $0.order < $1.order })
            }
            
            categories.sort {
                categoryOrder.firstIndex(of: $0.key) ?? categoryOrder.count < categoryOrder.firstIndex(of: $1.key) ?? categoryOrder.count
            }
            
            return categories
        } catch {
            throw error.firestoreError
        }
    }
    
    func updateCategory(category: Category) async throws {
        do {
            try await dbRef.document(category.id.uuidString).setData(category.dictionary)
        } catch {
            throw error.firestoreError
        }
    }
    
    func createCategory(category: Category) async throws {
        do {
            try await dbRef.document(category.id.uuidString).setData(category.dictionary)
        } catch {
            throw error.firestoreError
        }
    }
    
    func deleteCategory(category: Category) async throws {
        do {
            try await dbRef.document(category.id.uuidString).delete()
        } catch {
            throw error.firestoreError
        }
    }
    
    func updateCategories(categories: [Category]) async throws {
        await withThrowingTaskGroup(of: Void.self) { group in
            categories.forEach { category in
                group.addTask {
                    self.dbRef.document(category.id.uuidString).setData(category.dictionary)
                }
            }
        }
    }
}

class MockCategoryService: CategoryServiceProtocol {
    var categories: OrderedDictionary<String, [Category]> = [:]
    
    func getCategories() async throws -> OrderedDictionary<String, [Category]> {
        return initialCategories
    }
    
    func updateCategory(category: Category) async throws {
        
    }
    
    func createCategory(category: Category) async throws {
        
    }
    
    func deleteCategory(category: Category) async throws {
        
    }
    
    func updateCategories(categories: [Category]) async throws {
        
    }
    
    func getCategoryOrder() async throws -> [String] {
        return []
    }
    
    func updateCategoryOrder(order: [String]) async throws {
        
    }
}
