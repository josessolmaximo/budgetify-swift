//
//  Colors.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 06/12/22.
//

import SwiftUI

enum defaultColors: String, CaseIterable {
    case blue = "0#0.482#0.996#1.0"
    case green = "0.204#0.780#0.353#1.0"
    case purple = "0.682#0.325#0.871#1.0"
    case grey = "0.573#0.573#0.573#1.0"
    case orange = "1#0.584#0.008#1.0"
    case red = "1#0.227#0.184#1.0"
    case yellow = "1#0.8#0.004#1.0"
    case darkblue = "0.345#0.337#0.839#1.0"
    case lightblue = "0.353#0.784#0.984#1.0"
    case brown = "0.6#0.4#0.2#1.0"
}

extension defaultColors {
    var name: String {
        switch self {
        case .blue:
            return "Blue"
        case .green:
            return "Green"
        case .purple:
            return "Purple"
        case .grey:
            return "Grey"
        case .orange:
            return "Orange"
        case .red:
            return "Red"
        case .yellow:
            return "Yellow"
        case .darkblue:
            return "Dark Blue"
        case .lightblue:
            return "Light Blue"
        case .brown:
            return "Brown"
        }
    }
}
