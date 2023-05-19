//
//  TransactionItemViewModel.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 03/12/22.
//

import UIKit
import SwiftUI

class TransactionItemViewModel: ObservableObject {
    @Published var selectedIndex: [Int] = []
    @Published var images: [UIImage] = []
    @Published var isImagePickerShown: String?
    
    @Published var isLocationPickerShown = false
    @Published var isRecurringPopoverShown = false
    
    @Published var textViewHeight: CGFloat = 0
    @Published var selectedImage: Int?
    
    var transaction: Binding<Transaction>
    
    init(transaction: Binding<Transaction>){
        self.transaction = transaction
    }
    
    func removeImage(index: Int, id: String?, transactionSheetVM: TransactionSheetViewModel){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7){
            if transactionSheetVM.doesTransactionExist {
                if id == nil {
                    self.images.remove(at: index)
                    
                    self.transaction.wrappedValue.images.remove(at: index + self.transaction.images.count - 1)
                    self.transaction.wrappedValue.imagesData.remove(at: index)
                } else {
                    self.transaction.wrappedValue.images.remove(at: index)
                }
            } else {
                self.images.remove(at: index)
                self.transaction.wrappedValue.images.remove(at: index)
                self.transaction.wrappedValue.imagesData.remove(at: index)
            }
        }
    }
    
    func addImage(image: UIImage, imageData: Data, transactionSheetVM: TransactionSheetViewModel){
        DispatchQueue.main.async {
            transactionSheetVM.isCameraSheetShown = nil
            
            self.images.append(image)
            self.transaction.wrappedValue.images.append(UUID().uuidString)
            self.transaction.wrappedValue.imagesData.append(imageData)
        }
    }
}
