//
//  CustomIconView.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 20/12/22.
//

import SwiftUI
import CachedAsyncImage

struct CustomIconView: View {
    @EnvironmentObject var tm: ThemeManager
    
    let imageName: String
    let width: CGFloat
    let height: CGFloat
    
    init(imageName: String, dimensions: CGFloat = 25) {
        self.imageName = imageName
        self.width = dimensions
        self.height = dimensions
    }
    
    var body: some View {
        // Has to be an image, otherwise icons won't appear in menus
        if let url = URL(string: imageName), let _ = url.host {
            CachedAsyncImage(url: URL(string: imageName)) { img in
                img
                    .resizable()
                    .scaledToFit()
                    .frame(width: width, height: height)
            } placeholder: {
                tm.selectedTheme.tertiaryLabel
                    .frame(width: width, height: height)
            }
            .accessibilityIdentifier(imageName)
        } else if imageName.contains("custom.") ||
                    imageName.contains("logo.") ||
                    imageName.contains("icon.") ||
                    iOS15InvalidSymbols.contains(imageName) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: width, height: height)
                .accessibilityIdentifier(imageName)
        } else if imageName.length == 1, let image = imageName.image() {
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: width * 1.25, height: height * 1.25)
                    .accessibilityIdentifier(imageName)
                    
            }
            .frame(width: width, height: height)
//            .background(.red.opacity(0.5))
        } else {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: width, height: height)
                .accessibilityIdentifier(imageName)
        }
    }
}
