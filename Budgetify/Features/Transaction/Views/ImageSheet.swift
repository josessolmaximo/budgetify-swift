//
//  ImageSheet.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 18/11/22.
//

import SwiftUI

struct ImageSheet: View {
    @Environment(\.dismiss) var dismiss
    
    @State var selectedImage = 0
    
    var imagesString: [String] = []
    var images: [UIImage] = []
    
    init(imagesString: [String], selectedImage: Int) {
        self.imagesString = imagesString
        _selectedImage = State(initialValue: selectedImage)
    }
    
    init(images: [UIImage], selectedImage: Int) {
        self.images = images
        _selectedImage = State(initialValue: selectedImage)
    }
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            TabView(selection: $selectedImage) {
                if imagesString.isEmpty {
                    ForEach(Array(images.enumerated()), id:\.element) { index, image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .tag(index)
                    }
                } else {
                    ForEach(Array(imagesString.enumerated()), id:\.element) { index, image in
                        FirebaseImage(size: .large, id: image)
                            .tag(index)
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle())
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                    .padding(.vertical)
                    .padding(.horizontal, 10)
                }
                
                Spacer()
            }
        }
        .analyticsScreen(name: self.pageTitle, class: self.pageTitle)
    }
}

struct ImageSheet_Previews: PreviewProvider {
    static var previews: some View {
        ImageSheet(images: [], selectedImage: 0)
    }
}
