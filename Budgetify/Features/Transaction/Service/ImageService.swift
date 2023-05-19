//
//  ImageService.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 08/02/23.
//

import SwiftUI
import FirebaseStorage

protocol ImageServiceProtocol {
    func uploadImage(transaction: Transaction) async throws
    func updateImage(uneditedTransaction: Transaction, transaction: Transaction) async throws
    func deleteImage(id: String) async throws
}

class ImageService: ImageServiceProtocol {
    @AppStorage("selectedUserId", store: .grouped) var userId = ""
    
    let storageRef = Storage.storage().reference()
    
    func uploadImage(transaction: Transaction) async throws {
        do {
            for (index, data) in transaction.imagesData.enumerated() {
                let metadata = StorageMetadata()
                
                metadata.contentType = "image/jpg"
                
                let ref = storageRef.child("users/\(userId)/\(transaction.images[index]).jpg")
                let _ = try await ref.putDataAsync(data, metadata: metadata)
            }
        } catch {
            throw error
        }
    }
    
    func updateImage(uneditedTransaction: Transaction, transaction: Transaction) async throws {
        do {
            let difference = transaction.images.difference(from: uneditedTransaction.images)
            
            var count = 0
            
            for change in difference {
                switch change {
                case let .insert(_, element, _):
                    let metadata = StorageMetadata()
                    
                    metadata.contentType = "image/jpg"
                    
                    let imageRef = storageRef.child("users/\(userId)/\(element).jpg")
                    
                    let _ = try await imageRef.putDataAsync(transaction.imagesData[count], metadata: metadata)

                    count += 1
                case let .remove(_, element, _):
                    try await storageRef.child("users/\(userId)/\(element).jpg").delete()
                }
            }
        } catch {
            throw error
        }
    }
    
    func deleteImage(id: String) async throws {
        do {
            try await storageRef.child("users/\(userId)/\(id).jpg").delete()
        } catch {
            throw error
        }
    }
}
