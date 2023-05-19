//
//  SearchSheetView.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 16/01/23.
//

import SwiftUI
import OrderedCollections

struct SearchSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var vm = SearchSheetViewModel()
    
    @EnvironmentObject private var walletVM: WalletViewModel
    @EnvironmentObject private var categoryVM: CategoryViewModel
    @EnvironmentObject private var transactionVM: TransactionViewModel
    
    @EnvironmentObject private var tm: ThemeManager
    
    let isReport: Bool
    let onApply: (() -> Void)?
    
    init(isReport: Bool = false, onApply: (() -> Void)? = nil) {
        self.isReport = isReport
        self.onApply = onApply
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    SearchTextField(keyword: $vm.query.keyword, placeholder: "Categories, Wallets, Locations, Notes")
                    
                    HStack {
                        Text("Transaction Type")
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                vm.transactionTypeCollapse.toggle()
                            }
                        }, label: {
                            Image(systemName: vm.transactionTypeCollapse ? "chevron.down" : "chevron.up")
                        })
                        .tint(tm.selectedTheme.primaryColor)
                    }
                    .padding(.horizontal)
                    .padding(.top, 5)
                    
                    if !vm.transactionTypeCollapse && !isReport {
                        ForEach(TransactionType.allCases, id: \.self) { type in
                            Divider()
                            
                            HStack {
                                Text(type.rawValue)
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                Checkbox(isChecked: .constant(vm.query.transactionType[type] ?? false)) { checked in
                                    
                                    vm.query.transactionType[type] = checked
                                }
                            }
                            .frame(height: 35)
                        }
                        .padding(.horizontal)
                    } else {
                        VStack {
                            Divider()
                            
                            HStack {
                                Text(TransactionType.income.rawValue)
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                Checkbox(isChecked: .constant(vm.query.transactionType[TransactionType.income] ?? false)) { checked in
                                    
                                    vm.query.transactionType[TransactionType.expense] = !checked
                                    vm.query.transactionType[TransactionType.income] = checked
                                }
                            }
                            .frame(height: 35)
                            
                            Divider()
                            
                            HStack {
                                Text(TransactionType.expense.rawValue)
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                Checkbox(isChecked: .constant(vm.query.transactionType[TransactionType.expense] ?? false)) { checked in
                                    
                                    vm.query.transactionType[TransactionType.expense] = checked
                                    vm.query.transactionType[TransactionType.income] = !checked
                                }
                            }
                            .frame(height: 35)
                        }
                        .padding(.horizontal)
                    }
                    
                    HStack {
                        Text("Wallets")
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                vm.walletCollapse.toggle()
                            }
                        }, label: {
                            Image(systemName: vm.walletCollapse ? "chevron.down" : "chevron.up")
                        })
                        .tint(tm.selectedTheme.primaryColor)
                    }
                    .padding(.horizontal)
                    .padding(.top, 5)
                    
                    if !vm.walletCollapse {
                        ForEach(walletVM.wallets) { wallet in
                            Divider()
                            
                            HStack {
                                CustomIconView(imageName: wallet.image)
                                
                                Text(wallet.name)
                                    .fontWeight(.medium)
                                    .padding(.leading, 5)
                                
                                Spacer()
                                
                                Checkbox(isChecked: .constant(vm.query.wallets[wallet] ?? false)) { checked in
                                    
                                    vm.query.wallets[wallet] = checked
                                }
                            }
                            .frame(height: 35)
                        }
                        .padding(.horizontal)
                    }
                    
                    HStack {
                        Text("Categories")
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                vm.categoryCollapse.toggle()
                            }
                        }, label: {
                            Image(systemName: vm.categoryCollapse ? "chevron.down" : "chevron.up")
                        })
                        .tint(tm.selectedTheme.primaryColor)
                    }
                    .padding(.horizontal)
                    .padding(.top, 5)
                    
                    if !vm.categoryCollapse {
                        ForEach(categoryVM.categories.keys) { key in
                            Divider()
                            HStack {
                                Text(key)
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                let categoriesChecked = categoryVM.categories[key]?.map({vm.query.categories[$0] ?? false}) ?? []
                                
                                Checkbox(isChecked: .constant(!categoriesChecked.contains(false))) { checked in
                                    
                                    categoryVM.categories[key]?.forEach({ category in
                                        vm.query.categories[category] = categoriesChecked.contains(false)
                                    })
                                }
                                
                            }
                            .frame(height: 35)
                            
                                ForEach(categoryVM.categories[key] ?? []) { category in
                                    Divider()
                                    
                                    HStack {
                                        CustomIconView(imageName: category.image)
                                            .foregroundColor(category.color.stringToColor())
                                        
                                        Text(category.name)
                                            .fontWeight(.medium)
                                            .padding(.leading, 5)
                                            .foregroundColor(category.color.stringToColor())
                                        
                                        Spacer()
                                        
                                        Checkbox(isChecked: .constant(vm.query.categories[category] ?? false)) { checked in
                                            
                                            vm.query.categories[category] = checked
                                        }
                                    }
                                    .frame(height: 35)
                                }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
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
                    if !vm.loading {
                        Button(role: .destructive) {
                            transactionVM.setup(wallets: walletVM.wallets, categories: categoryVM.categories.values.reduce([], +), isReport: isReport)
                            vm.query = transactionVM.query
                        } label: {
                            Text("Reset")
                        }
                        .foregroundColor(.red)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if vm.loading {
                        ProgressView()
                            .tint(tm.selectedTheme.tintColor)
                    } else {
                        Button("Apply") {
                            transactionVM.query = vm.query
                            
                            dismiss()
                            
                            transactionVM.filterTransactions(transactions: transactionVM.unfilteredTransactions, wallets: walletVM.wallets, categories: categoryVM.categories.values.reduce([], +))
                            
                            onApply?()
                        }
                        .foregroundColor(tm.selectedTheme.tintColor)
                    }
                }
            }
        }
        .onAppear {
            if transactionVM.query.transactionType.isEmpty ||
                transactionVM.query.wallets.isEmpty ||
                transactionVM.query.categories.isEmpty {
                transactionVM.setup(wallets: walletVM.wallets, categories: Array(categoryVM.categories.values).reduce([], +), isReport: isReport)
            }
            
            vm.query = transactionVM.query
        }
        .analyticsScreen(name: self.pageTitle, class: self.pageTitle)
    }
}

struct SearchSheetView_Previews: PreviewProvider {
    static var previews: some View {
        SearchSheetView()
            .environmentObject(ThemeManager())
            .environmentObject(WalletViewModel(walletService: MockWalletService()))
            .environmentObject(CategoryViewModel(categoryService: MockCategoryService()))
//            .environmentObject(TransactionViewModel(transactionService: MockTransactionService()))
    }
}
