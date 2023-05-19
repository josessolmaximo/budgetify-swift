//
//  LoginService.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 19/12/22.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseFunctions

protocol LoginServiceProtocol {
    func signOut() async throws
    func deleteAccount() async throws
    func deleteUserData() async throws
    func checkIfUserExists(id: String) async throws
}

class LoginService: LoginServiceProtocol {
    @AppStorage("userId", store: .grouped) var userId: String = ""
    @AppStorage("doesUserExist", store: .grouped) var doesUserExist = true
    
    let db = Firestore.firestore()
    let cfRef = Functions.functions()
    
    func signOut() async throws {
        do {
            try Auth.auth().signOut()
        } catch {
            throw error.firestoreError
        }
    }
    
    func deleteAccount() async throws {
        do {
            try await Auth.auth().currentUser?.delete()
        } catch {
            throw ServiceError.generalError(description: "An Error Occured", recovery: error.localizedDescription)
        }
    }
    
    func deleteUserData() async throws {
        let categoryService = CategoryService()
        
        do {
            let _ = try await cfRef.httpsCallable("deleteUserCollection").call([
                "userId": userId,
            ])
            
            let initialCategoryValues = Array(initialCategories.values).flatMap({ (element: [Category]) -> [Category] in
                return element
            })
            
            try await categoryService.updateCategories(categories: initialCategoryValues)
        } catch {
            throw error.firestoreError
        }
    }
    
    func checkIfUserExists(id: String) async throws {
        let categoryService = CategoryService()
        
        let docRef = db.collection("users").document(id)
        
        do {
            let document = try await docRef.getDocument()
            
            if !document.exists {
                doesUserExist = false
                
                try await docRef.setData(["createdAt": Date()])
                
                let initialCategoryValues = Array(initialCategories.values).flatMap({ (element: [Category]) -> [Category] in
                    return element
                })
                
                try await categoryService.updateCategories(categories: initialCategoryValues)
            } else {
                doesUserExist = true
            }
        } catch let error as ServiceError {
            ErrorManager.shared.logError(error: error, vm: self)
        } catch {
            throw error.firestoreError
        }
    }
}

class MockLoginService: LoginServiceProtocol {
    func signOut() async throws {
        
    }
    
    func deleteAccount() async throws {
        
    }
    
    func deleteUserData() async throws {
        
    }
    
    func checkIfUserExists(id: String) async throws {
        
    }
}
