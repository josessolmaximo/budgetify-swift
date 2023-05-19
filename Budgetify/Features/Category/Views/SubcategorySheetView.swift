//
//  SubcategorySheetView.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 29/11/22.
//

import SwiftUI
import FirebaseAnalyticsSwift

struct SubcategorySheetView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var categoryVM: CategoryViewModel
    @EnvironmentObject var walletVM: WalletViewModel
    
    @EnvironmentObject var tm: ThemeManager
    
    @StateObject var em = ErrorManager.shared
    @StateObject var vm: SubcategorySheetViewModel
    
    let initialCategory: Category
    
    init(category: Category, parentVM: SubcategorySheetProtocol) {
        self._vm = StateObject(wrappedValue: SubcategorySheetViewModel(category: category, parentVM: parentVM))
        self.initialCategory = category
    }
    
    var body: some View {
        NavigationView {
            VStack {
                IconPickerField(text: $vm.category.name, image: $vm.category.image)
                
                category
                
                type
                
                wallet
                
                hidden
                
                color
                
                if !initialCategory.name.isEmpty {
                    HStack {
                        Text("Order")
                        
                        TextField("", value: $vm.category.order, format: .number)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(tm.selectedTheme.primaryLabel)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    InfoBox(text: "Editing or deleting this subcategory will change previous transactions.")
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $vm.isDeleteAlertShown, content: {
                Alert(
                    title: Text("Delete Subcategory?"),
                    message: Text("Deleting this subcategory will delete references to this subcategory from previous transactions"),
                    primaryButton: .destructive(Text("Delete"), action: {
                        Task {
                            await vm.deleteCategory(category: vm.category)
                        }
                    }),
                    secondaryButton: .cancel(Text("Cancel")))
            })
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !vm.loading {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(tm.selectedTheme.tintColor)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !initialCategory.name.isEmpty && !vm.loading {
                        deleteButton
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if vm.loading {
                        ProgressView()
                            .tint(tm.selectedTheme.tintColor)
                    } else {
                        Button(initialCategory.name.isEmpty ? "Add" : "Save") {
                            if initialCategory.name.isEmpty {
                                if PremiumManager.shared.isPremium || categoryVM.categories.values.reduce([], +).count < defaultCategories.count + ConfigManager.shared.paywallLimits["subcategories"]! {
                                    Task {
                                        await vm.createCategory(category: vm.category)
                                    }
                                } else {
                                    ErrorManager.shared.premiumError = true
                                }
                            } else {
                                Task {
                                    await vm.updateCategory(category: vm.category)
                                }
                            }
                        }
                        .foregroundColor(tm.selectedTheme.tintColor)
                    }
                }
                
                ToolbarItem(placement: .keyboard) {
                    KeyboardToolbar()
                }
            }
            .onChange(of: vm.shouldSheetDismiss) { value in
                if value {
                    dismiss()
                }
            }
            .onChange(of: vm.category.categoryHeader) { category in
                if categoryVM.categories.keys.contains(category){
                    vm.customCategoryField = false
                }
                
                vm.category.order = categoryVM.categories[category]?.count ?? 0
                
                let colors = categoryVM.categories[category]?.map({$0.color}) ?? []
                
                let counts = colors.reduce(into: [:]) { counts, element in
                    counts[element, default: 0] += 1
                }

                if let (value, _) = counts.max(by: { $0.value < $1.value }) {
                    vm.category.color = value
                }
            }
        }
        .analyticsScreen(name: self.pageTitle, class: self.pageTitle)
        .errorAlert(error: $em.serviceError)
        .errorAlert(error: $em.validationError)
        .sheet(isPresented: $em.premiumError, content: {
            PremiumSheetView()
        })
    }
}

struct SubcategorySheetView_Previews: PreviewProvider {
    static var previews: some View {
        let defaultExpenseCategory = Category(categoryHeader: "Food & Drinks", name: "Food", image: "fork.knife", order: 0, type: .expense, color: defaultColors.blue.rawValue)
        
        SubcategorySheetView(category: defaultExpenseCategory, parentVM: CategoryViewModel(categoryService: MockCategoryService()))
            .environmentObject(CategoryViewModel(categoryService: MockCategoryService()))
            .environmentObject(WalletViewModel(walletService: MockWalletService()))
            .environmentObject(ThemeManager())
    }
}

extension SubcategorySheetView {
    var deleteButton: some View {
        Button(role: .destructive) {
            vm.isDeleteAlertShown.toggle()
        } label: {
            Text("Delete")
        }
        .foregroundColor(.red)
    }
    
    var hidden: some View {
        HStack {
            Text("Hidden")
            
            Spacer()
            
            Checkbox(isChecked: $vm.category.isHidden)
        }
        .frame(height: 30)
    }
    
    var color: some View {
        HStack {
            Text("Color")
            
            Spacer()
            
            let color: Binding<Color> = Binding(
                get: { vm.category.color.stringToColor() },
                set: { vm.category.color = ($0.cgColor?.components?.map(String.init).joined(separator: "#"))! }
            )
            
            Menu {
                Picker("", selection: $vm.category.color) {
                    ForEach(defaultColors.allCases, id: \.self) { color in
                        HStack {
                            Text(color.name)
                            Image(uiImage: UIImage(systemName: "circle.fill")!.withTintColor(UIColor(cgColor: color.rawValue.stringToColor().cgColor!), renderingMode: .alwaysOriginal))
                        }
                        .tag(color.rawValue)
                    }
                }
            } label: {
                Image(systemName: "circle.fill")
                    .foregroundColor(vm.category.color.stringToColor())
            }
            
            Divider()

            ColorPicker("", selection: color)
                .labelsHidden()
        }
        .frame(height: 30)
    }
    
    var wallet: some View {
        HStack {
            Text("Default Wallet")
            
            Spacer()
            
            Menu {
                Picker("", selection: $vm.category.defaultWallet) {
                    ForEach(walletVM.wallets) { wallet in
                        HStack {
                            Text(wallet.name)
                            CustomIconView(imageName: wallet.image)
                        }
                        .tag(wallet.id.uuidString)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("None")
                        CustomIconView(imageName: "circle.slash")
                    }
                    .tag("")
                }
            } label: {
                let wallet = walletVM.getWalletById(id: vm.category.defaultWallet)
                
                if wallet != nil {
                    CustomIconView(imageName: wallet?.image ?? "")
                }
                
                Text(wallet?.name ?? "None")
                    .fontWeight(.semibold)
            }
            .foregroundColor(tm.selectedTheme.primaryColor)
        }
        .frame(height: 30)
    }
    
    var type: some View {
        HStack {
            Text("Transaction Type")
            
            Spacer()
            
            Menu {
                Picker("", selection: $vm.category.type) {
                    Text(TransactionType.expense.rawValue)
                        .tag(TransactionType.expense)
                    
                    Text(TransactionType.income.rawValue)
                        .tag(TransactionType.income)
                }
            } label: {
                Text(vm.category.type.rawValue)
                    .fontWeight(.semibold)
            }
            .foregroundColor(tm.selectedTheme.primaryColor)
        }
        .frame(height: 30)
    }
    
    @ViewBuilder
    var category: some View {
        HStack {
            Text("Category")
            
            Spacer()
            
            Menu {
                Picker("", selection: $vm.category.categoryHeader) {
                    ForEach(categoryVM.categories.elements, id: \.key){ key, value in
                        HStack {
                            Text(key)
                            CustomIconView(imageName: value.first?.image ?? "")
                        }
                        .tag(key)
                    }
                    
                    Divider()
                }
                
                Button(action: {
                    if PremiumManager.shared.isPremium {
                        vm.category.categoryHeader = ""
                        vm.customCategoryField = true
                    } else {
                        ErrorManager.shared.premiumError = true
                    }
                }, label: {
                    HStack {
                        Text("Custom")
                        Image(systemName: "plus")
                    }
                })
                .tag("")
            } label: {
                Text(vm.customCategoryField ? "Custom" : vm.category.categoryHeader)
                    .fontWeight(.semibold)
            }
            .foregroundColor(tm.selectedTheme.primaryColor)
        }
        .frame(height: 30)
        
        if vm.customCategoryField {
            HStack {
                TextField("Custom Category Name", text: $vm.category.categoryHeader)
                    .textFieldStyle(.roundedBorder)
            }
            .frame(height: 30)
        }
    }
}
