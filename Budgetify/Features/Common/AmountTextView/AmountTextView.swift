//
//  AmountTextView.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 19/03/23.
//

import SwiftUI

struct AmountTextView: View {
    @ObservedObject var sm = SettingsManager.shared
    
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .redacted(reason: sm.amountsVisible ? [] : .placeholder)
    }
}
