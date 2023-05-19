//
//  AddButton.swift
//  WidgetsExtension
//
//  Created by Joses Solmaximo on 28/04/23.
//

import SwiftUI

struct AddButton: View {
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                
                VStack {
                    Link(destination: URL(string: "budgetify://transaction")!) {
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: 25, height: 25)
                            .foregroundColor(Color(uiColor: .systemGray6))
                            .overlay(
                                Image(systemName: "plus")
                                    .font(.system(size: 15, weight: .medium))
                                    .padding(5)
                            )
                    }
                    .padding([.top, .trailing], 10)
                    .padding(.top, 5)
                    
                    Spacer()
                }
            }
        }
    }
}
