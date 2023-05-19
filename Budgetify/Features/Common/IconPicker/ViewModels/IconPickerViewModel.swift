//
//  IconPickerViewModel.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 24/11/22.
//

import UIKit
import OrderedCollections

class IconPickerViewModel: ObservableObject {
    @Published var iconType: IconType = .system
    @Published var category: String = ""
    @Published var searchText = ""
    @Published var emojiText = ""
    @Published var favIcons: [FavIcon] = []
    
    @Published var favIconURLs: [String] = []
    
    @Published var isFavIconLoading = false
    
    @MainActor
    func requestFavIconUrl(domain: String) async {
        isFavIconLoading = true
        
        var domain = domain
        let favIconGrabberURL = "https://favicongrabber.com/api/grab"
        let favIconKitURL = "https://sensitive-gray-dinosaur.faviconkit.com"
        let favIconGoogleURL = "https://www.google.com/s2/favicons"
        let favIconDDGURL = "https://icons.duckduckgo.com/ip3"
        
        favIcons = []
        
        if domain.prefix(7) != "http://" && domain.prefix(8) != "https://" {
            domain = "https://" + domain
        }
        
        do {
            guard let url = URL(string: domain),
                  let host = url.host,
                  let hostURL = URL(string: "\(favIconGrabberURL)/\(host)")
            else {
                throw ServiceError.favIconError(code: .invalidURL)
            }
            
            let (data, _) = try await URLSession.shared.data(from: hostURL)
            
            self.favIcons.append(.init(src: "\(favIconKitURL)/\(host)/64", sizes: "64x64", provider: .favIconKit))
            self.favIcons.append(.init(src: "\(favIconKitURL)/\(host)/128", sizes: "128x128", provider: .favIconKit))
            self.favIcons.append(.init(src: "\(favIconKitURL)/\(host)/256", sizes: "256x256", provider: .favIconKit))
            
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let icons = json["icons"] as? [[String: Any]] {
                for icon in icons {
                    if let src = icon["src"] as? String, !src.isEmpty {
                        self.favIcons.append(.init(src: src, sizes: icon["sizes"] as? String, provider: .favIconGrabber))
                    }
                }
            }
            
            self.favIcons.append(.init(src: "\(favIconGoogleURL)?domain=\(host)&sz=64", sizes: "64x64", provider: .google))
            self.favIcons.append(.init(src: "\(favIconGoogleURL)?domain=\(host)&sz=128", sizes: "128x128", provider: .google))
            self.favIcons.append(.init(src: "\(favIconGoogleURL)?domain=\(host)&sz=256", sizes: "256x256", provider: .google))
            
            self.favIcons.append(.init(src: "\(favIconDDGURL)/\(host).ico", sizes: "", provider: .duckDuckGo))
            
            self.favIcons.append(.init(src: "https://\(host)/favicon.ico", sizes: "", provider: .source))
            
            self.favIcons.append(.init(src: "https://icon.horse/icon/\(host)", sizes: "", provider: .iconHorse))
            
            let biURL = URL(string: "https://besticon-demo.herokuapp.com/allicons.json?url=\(host)")!
            let (biData, _) = try await URLSession.shared.data(from: biURL)
            
            if let json = try? JSONSerialization.jsonObject(with: biData, options: []) as? [String: Any] {
                if let icons = json["icons"] as? [[String: Any]] {
                    
                    for icon in icons {
                        if let src = icon["url"] as? String, !src.isEmpty {
                            if let size = icon["height"] as? Int {
                                self.favIcons.append(.init(src: src, sizes: "\(size)x\(size)", provider: .bestIcon))
                            } else {
                                self.favIcons.append(.init(src: src, sizes: "", provider: .bestIcon))
                            }
                        }
                    }
                }
            }
        } catch {
            ErrorManager.shared.serviceError = error as? ServiceError
        }
        
        isFavIconLoading = false
    }
}
