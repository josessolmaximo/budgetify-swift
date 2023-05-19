//
//  SearchSheetViewModel.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 16/01/23.
//

import Foundation

class SearchSheetViewModel: ObservableObject {
    @Published private(set) var loading = false
    
    @Published var keyword: String = ""
    
    @Published var isEditing = false
    
    @Published var transactionTypeCollapse = false
    @Published var walletCollapse = false
    @Published var categoryCollapse = true
    
    @Published var query = TransactionQuery()
    
    func setup(query: TransactionQuery){
        self.query = query
    }
}
