//
//  ProfilePictureView.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 04/01/23.
//

import SwiftUI
import CachedAsyncImage

struct ProfilePictureView: View {
    @EnvironmentObject var tm: ThemeManager
    
    let photoURL: URL?
    let dimensions: CGFloat
    
    var body: some View {
        if let photoURL = photoURL {
            CachedAsyncImage(url: photoURL) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                tm.selectedTheme.tertiaryLabel
            }
            .frame(width: dimensions, height: dimensions)
            .cornerRadius(dimensions/2)
        } else {
            Image(systemName: "person.crop.circle")
                .resizable()
                .scaledToFit()
                .frame(width: dimensions, height: dimensions)
        }
    }
}
