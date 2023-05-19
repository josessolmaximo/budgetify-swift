//
//  CustomBackButton.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 04/01/23.
//

import SwiftUI

struct CustomBackButtonModifier: ViewModifier {
    @EnvironmentObject var tm: ThemeManager
    
    let dismiss: DismissAction
    
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17).weight(.medium))
                    }
                    .foregroundColor(tm.selectedTheme.primaryColor)
                }
            }
    }
}
