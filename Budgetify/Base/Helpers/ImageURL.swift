//
//  ImageURL.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 02/10/22.
//

import FirebaseStorage
import SwiftUI

class ImageURL: ObservableObject {
    @Published var imageURL : URL?
    
    @AppStorage("selectedUserId", store: .grouped) var selectedUserId = ""
    
    func getURL(id: String) {
        let storage = Storage.storage()
        
        storage.reference().child("users/\(selectedUserId)/\(id).jpg").downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                return
            }
            self.imageURL = url
        })
    }
}
