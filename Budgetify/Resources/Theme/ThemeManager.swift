//
//  ThemeManager.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 23/12/22.
//

import Foundation

class ThemeManager: ObservableObject {
    @Published var selectedTheme: Theme = DefaultTheme()
}
