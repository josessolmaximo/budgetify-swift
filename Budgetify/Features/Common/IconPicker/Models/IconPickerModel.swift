//
//  IconPickerModel.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 24/11/22.
//

import Foundation

enum IconType: String, CaseIterable {
    case system = "System"
    case custom = "Custom"
    case logo = "Logo"
    case favicon = "Favicon"
    case emoji = "Emoji"
}

enum FavIconErrorCode {
    case invalidURL
    case dataNotFound
}

struct FavIcon: Identifiable {
    var id = UUID()
    var src: String?
    var sizes: String?
    var provider: FavIconProvider
    
    var isRecommended: Bool {
        let recommendedProviders: [FavIconProvider] = [.google, .duckDuckGo, .source]
        
        return recommendedProviders.contains(provider)
    }
}

enum FavIconProvider: String, Hashable {
    case favIconKit = "FavIconKit"
    case favIconGrabber = "FavIconGrabber"
    case google = "Google"
    case duckDuckGo = "DuckDuckGo"
    case bestIcon = "BestIcon"
    case source = "Source"
    case iconHorse = "IconHorse"
}
