//
//  Theme.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 23/12/22.
//

import SwiftUI

protocol Theme {
    var primaryColor: Color { get }
    var secondaryColor: Color { get }
    
    var backgroundColor: Color { get }
    var tintColor: Color { get }
    var disabledColor: Color { get }
    
    var primaryLabel: Color { get }
    var secondaryLabel: Color { get }
    var tertiaryLabel: Color { get }
}

struct DefaultTheme: Theme {
    var primaryColor = Color("default.primaryColor")
    var secondaryColor = Color("default.secondaryColor")
    
    var backgroundColor = Color("default.backgroundColor")
    
    var tintColor = Color("default.tintColor")
    
    var disabledColor = Color(uiColor: .systemGray4)
    
    var primaryLabel = Color("default.primaryLabel")
    var secondaryLabel = Color("default.secondaryLabel")
    var tertiaryLabel = Color("default.tertiaryLabel")
}
