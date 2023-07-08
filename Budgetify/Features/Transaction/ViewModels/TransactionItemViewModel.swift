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
}
