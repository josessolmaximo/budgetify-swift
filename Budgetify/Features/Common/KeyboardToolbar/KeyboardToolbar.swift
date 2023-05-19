//
//  KeyboardToolbar.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 23/04/23.
//

import SwiftUI

struct KeyboardToolbar: View {
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var tm: ThemeManager
    
    var body: some View {
        HStack {
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Button(action: {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }, label: {
                Image(systemName: "keyboard.chevron.compact.down")
            })
            .foregroundColor(tm.selectedTheme.primaryColor)
            .offset(x: 8)
        }
        .background(
            // Original RGB values: 209 211 217
            // Adjusted RGB values: 201 205 211
            
            Color("Keyboard")
                .padding(.horizontal, -20)
                .padding(.vertical, -6)
        )
    }
}

struct KeyboardToolbar_Previews: PreviewProvider {
    static var previews: some View {
        KeyboardToolbar()
    }
}
