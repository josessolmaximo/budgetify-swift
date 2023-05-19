//
//  IconPickerField.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 28/04/23.
//

import SwiftUI

struct IconPickerField: View {
    @EnvironmentObject var tm: ThemeManager
    
    @Binding var text: String
    @Binding var image: String
    
    @State var isIconPickerShown = false
    
    var body: some View {
        HStack {
            NavigationLink {
                IconPickerView { image in
                    self.image = image
                }
            } label: {
                CustomIconView(imageName: image)
            }

//            Button(action: {
//                isIconPickerShown.toggle()
//            }, label: {
//                CustomIconView(imageName: image)
//            })
            .foregroundColor(tm.selectedTheme.primaryColor)
            .accessibilityIdentifier("iconPicker")
            
            Rectangle()
                .frame(width: 1, height: 30)
                .padding(.horizontal, 5)
                .foregroundColor(tm.selectedTheme.tertiaryLabel)
            
            TextField("Name", text: $text)
                .accessibilityIdentifier("nameTextfield")
        }
//        .sheet(isPresented: $isIconPickerShown) {
//            IconPickerView { image in
//                self.image = image
//            }
//        }
    }
}
