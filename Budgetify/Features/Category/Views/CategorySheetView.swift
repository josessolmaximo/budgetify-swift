//
//  CategorySheetView.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 26/01/23.
//

import SwiftUI

struct CategorySheetView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var categoryVM: CategoryViewModel
    @EnvironmentObject var tm: ThemeManager
    
    @StateObject var vm: CategorySheetViewModel
    
    
    init(name: String, color: Color, categories: [Category]){
        _vm = StateObject(wrappedValue: CategorySheetViewModel(name: name, color: color, categories: categories))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Name", text: $vm.name)
                }
                
                HStack {
                    ColorPicker(selection: $vm.color) {
                        Label("Color", systemImage: "paintpalette")
                    }
                }
                
                HStack(alignment: .top) {
                    Image(systemName: "info.circle")
                    
                    Text("Updating categories will not update previous transactions, it will only affect new or updated transactions.")
                    
                    Spacer()
                }
                .font(.subheadline)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(tm.selectedTheme.primaryLabel.opacity(0.5), lineWidth: 1)
                )
                
                Spacer()
            }
            .padding(.horizontal)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(tm.selectedTheme.tintColor)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await vm.updateCategories(categoryVM: categoryVM)
                        }
                    }
                    .foregroundColor(tm.selectedTheme.tintColor)
                }
            }
        }
        .analyticsScreen(name: self.pageTitle, class: self.pageTitle)
        .onChange(of: vm.shouldSheetDismiss) { shouldDismiss in
            if shouldDismiss {
                dismiss()
            }
        }
    }
}

struct CategorySheetView_Previews: PreviewProvider {
    static var previews: some View {
        CategorySheetView(name: "Food & Drinks", color: defaultColors.blue.rawValue.stringToColor(), categories: [])
            .environmentObject(ThemeManager())
    }
}
