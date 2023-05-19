//
//  Checkbox.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 22/12/22.
//

import SwiftUI

struct Checkbox: View {
    @EnvironmentObject var tm: ThemeManager
    
    @Binding var isChecked: Bool
    
    public var onChecked: ((_ checked: Bool) -> Void)? = nil
    
    var body: some View {
        Button(action: {
            onChecked?(!isChecked)
            isChecked.toggle()
        }, label: {
            if isChecked {
                Image(systemName: "checkmark.square")
                    .accessibilityIdentifier("checkmark.square")
            } else {
                Image(systemName: "square")
                    .accessibilityIdentifier("square")
            }
        })
        .foregroundColor(tm.selectedTheme.primaryColor)
    }
}

struct Checkbox_Previews: PreviewProvider {
    static var previews: some View {
        Checkbox(isChecked: .constant(true))
    }
}
