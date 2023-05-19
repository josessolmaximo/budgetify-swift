//
//  InfoBox.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 29/01/23.
//

import SwiftUI

struct InfoBox: View {
    @EnvironmentObject var tm: ThemeManager
    
    let text: String
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "info.circle")
            
            Text(text)
            
            Spacer()
        }
        .font(.subheadline)
        .padding(10)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(tm.selectedTheme.primaryLabel.opacity(0.5), lineWidth: 1)
        )
    }
}

struct InfoBox_Previews: PreviewProvider {
    static var previews: some View {
        InfoBox(text: "Text")
            .environmentObject(ThemeManager())
    }
}
