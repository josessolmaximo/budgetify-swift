//
//  CategoryView.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 28/10/22.
//

import SwiftUI
import UniformTypeIdentifiers
import FirebaseAnalyticsSwift

struct CategoryView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var vm: CategoryViewModel
    @EnvironmentObject var tm: ThemeManager
    
    var body: some View {
        ZStack {
            tm.selectedTheme.backgroundColor
                .ignoresSafeArea()
            
            ScrollView {
                ForEach(vm.categories.keys) { section in
                    HStack {
                        Text(section.uppercased())
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                    }
                    
                    VStack {
                        ForEach(Array(stride(from: 0, to: (vm.categories[section]?.count ?? 0), by: 4)), id: \.self) { index in
                            HStack {
                                categoryCell(categories: vm.categories[section] ?? [], index: index)
                                categoryCell(categories: vm.categories[section] ?? [], index: index + 1)
                                categoryCell(categories: vm.categories[section] ?? [], index: index + 2)
                                categoryCell(categories: vm.categories[section] ?? [], index: index + 3)
                            }
                        }
                    }
                    .padding(.vertical, 10)
                }
                .padding(.top, 10)
                .padding(.horizontal)
            }
            .redacted(reason: vm.loading ? .placeholder : [])
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        vm.selectedSubcategory = Category(categoryHeader: vm.categories.keys.first ?? "", name: "", image: "tray", order: 0, type: .expense, color: defaultColors.blue.rawValue)
                    }, label: {
                        Image(systemName: "plus")
                    })
                    .foregroundColor(tm.selectedTheme.primaryLabel)
                }
            })
            .modifier(CustomBackButtonModifier(dismiss: dismiss))
            .sheet(item: $vm.selectedSubcategory, content: { subcategory in
                SubcategorySheetView(category: subcategory, parentVM: vm)
            })
            .refreshable {
                Task {
                    await vm.getCategories()
                }
            }
        }
        .analyticsScreen(name: self.pageTitle, class: self.pageTitle)
    }
}

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryView()
            .environmentObject(CategoryViewModel(categoryService: MockCategoryService()))
            .environmentObject(ThemeManager())
    }
}

extension CategoryView {
    func categoryCell(categories: [Category], index: Int) -> some View {
        ZStack {
            VStack {
                if index < categories.count {
                    let isHidden = !categories[index].isHidden
                    CustomIconView(imageName: categories[index].image)
                        .foregroundColor(isHidden ? categories[index].color.stringToColor() : Color("#929292"))
                    
                    Text(categories[index].name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.01)
                        .foregroundColor(isHidden ? categories[index].color.stringToColor() : Color("#929292"))
                    
                    Spacer()
                    
                }
            }
            .onTapGesture {
                vm.selectedSubcategory = categories[index]
            }
            
            Color.clear
        }
        .frame(minHeight: 60)
        
    }
}
