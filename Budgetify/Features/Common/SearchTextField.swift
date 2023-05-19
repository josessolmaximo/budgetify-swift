//
//  SearchTextField.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 18/01/23.
//

import SwiftUI

struct SearchTextField: View {
    @Binding var keyword: String
    
    @FocusState var isFocused: Bool
    
    let placeholder: String
    
    var body: some View {
        TextField("", text: $keyword)
            .focused($isFocused)
            .padding(7)
            .padding(.horizontal, 25)
            .background(Color("searchTextField"))
            .cornerRadius(8)
            .padding(.horizontal, 10)
            .overlay(
                HStack(spacing: 5) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .padding(.leading, 18)
                        .allowsHitTesting(false)
                    
                    Text(placeholder)
                        .foregroundColor(.gray)
                        .opacity(keyword.isEmpty ? 1 : 0)
                        .allowsHitTesting(false)
                    Spacer()

                    if isFocused && !keyword.isEmpty {
                        Button(action: {
                            keyword = ""
                        }) {
                            Image(systemName: "multiply.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, 18)
                        }
                    }
                }
            )
    }
}
