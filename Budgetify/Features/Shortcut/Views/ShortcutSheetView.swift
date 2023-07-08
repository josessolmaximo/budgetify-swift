//
//  ShortcutSheetView.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 27/04/23.
//

import SwiftUI

struct ShortcutSheetView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject private var walletVM: WalletViewModel
    @EnvironmentObject private var categoryVM: CategoryViewModel
    @EnvironmentObject private var shortcutVM: ShortcutViewModel
    @EnvironmentObject private var tm: ThemeManager
    
    @StateObject private var vm: ShortcutSheetViewModel
    @StateObject private var transactionSheetVM: TransactionSheetViewModel
    
    init(shortcut: Shortcut){
        self._vm = StateObject(wrappedValue: ShortcutSheetViewModel(shortcut: shortcut))
        
        self._transactionSheetVM = StateObject(wrappedValue: TransactionSheetViewModel(transactions: shortcut.transactions, isViewMode: false, isRecurringMode: false))
    }
    
    var body: some View {
        NavigationView {
            let isUpdate = shortcutVM.shortcuts.contains(where: { $0.id == vm.shortcut.id })
            
            GeometryReader { proxy in
                let fitsWidth = proxy.size.width - 40 >= 350
                
                VStack(spacing: 5) {
                    HStack {
                        IconPickerField(text: $vm.shortcut.name, image: $vm.shortcut.image)
                        
                        let color: Binding<Color> = Binding(
                            get: { vm.shortcut.color.stringToColor() },
                            set: { vm.shortcut.color = ($0.cgColor?.components?.map(String.init).joined(separator: "#"))! }
                        )
                        
                        Menu {
                            Picker("", selection: $vm.shortcut.color) {
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
                                .foregroundColor(vm.shortcut.color.stringToColor())
                        }
                        
                        Divider()
                        
                        ColorPicker("", selection: color)
                            .labelsHidden()
                    }
                    .padding(.horizontal)
                    .frame(height: 30)
                    
                    HStack {
                        Text("Slot")
                        
                        Spacer()
                        
                        Menu {
                            let pickedSlots = shortcutVM.shortcuts.map({ shortcut in
                                return shortcut.slot
                            })
                            
                            let slots = (1...8)
                            
                            let unpickedSlots = slots.filter({ !pickedSlots.contains($0) })
                            
                            Picker("", selection: $vm.shortcut.slot) {
                                Text("Hidden")
                                    .tag(0)
                            }
                            
                            Section("Available Slots") {
                                Picker("", selection: $vm.shortcut.slot) {
                                    ForEach(unpickedSlots, id: \.self) { slot in
                                        Text("Slot \(slot)")
                                            .tag(slot)
                                    }
                                }
                            }
                            
                            Section("Picked Slots") {
                                Picker("", selection: $vm.shortcut.slot) {
                                    ForEach(pickedSlots, id: \.self) { slot in
                                        Text("Slot \(slot)")
                                            .tag(slot)
                                    }
                                }
                                .disabled(true)
                            }
                        } label: {
                            if vm.shortcut.slot == 0 {
                                Text("Hidden")
                                    .fontWeight(.semibold)
                            } else {
                                Text("Slot \(vm.shortcut.slot)")
                                    .fontWeight(.semibold)
                            }
                        }
                        .foregroundColor(tm.selectedTheme.primaryColor)
                    }
                    .padding(.horizontal)
                    .frame(height: 30)
                    
                    HStack {
                        Text("Allow editing before adding")
                        
                        Spacer()
                        
                        Checkbox(isChecked: $vm.shortcut.editBeforeAdding)
                    }
                    .padding(.horizontal)
                    .frame(height: 30)
                    
                    HStack {
                        Text("TRANSACTIONS")
                            .fontWeight(.semibold)
                        
                        Spacer()
                    }
                    .font(.subheadline)
                    .padding(.horizontal)
                    .padding(.top, 5)
//                    .background(
//                        Rectangle()
//                            .frame(height: 1)
//                            .foregroundColor(tm.selectedTheme.tertiaryLabel)
//                            .offset(y: 17.5)
//                    )
                    
                    Divider()
                    
                    ScrollView {
                        LazyVStack {
                            Spacer()
                                .frame(height: 5)
                            
                            ForEach(transactionSheetVM.transactions) { transaction in
                                TransactionItemView(transaction: transaction, mode: .shortcut) { transaction in
                                    if let index = transactionSheetVM.transactions.firstIndex(where: { $0.id == transaction.id }) {
                                        transactionSheetVM.transactions[index] = transaction
                                    }
                                }
                                .padding(.horizontal, fitsWidth ? 18 : (proxy.size.width - 351) / 2)
                                .environmentObject(transactionSheetVM)
                            }
                            
                            Button(action: {
                                if let defaultWallet = walletVM.wallets.first(where: { $0.isDefault })?.id.uuidString {
                                    transactionSheetVM.transactions.append(Transaction(category: categoryVM.getDefaultCategory(type: .expense), note: "", amount: nil, originWallet: defaultWallet, destinationWallet: defaultWallet))
                                } else if let firstWallet = walletVM.wallets.first?.id.uuidString {
                                    transactionSheetVM.transactions.append(Transaction(category: categoryVM.getDefaultCategory(type: .expense), note: "", amount: nil, originWallet: firstWallet, destinationWallet: firstWallet))
                                }
                            }, label: {
                                Image(systemName: "plus")
                                Text("Add Transaction")
                            })
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if transactionSheetVM.transactions.isEmpty {
                    if let defaultWallet = walletVM.wallets.first(where: { $0.isDefault })?.id.uuidString {
                        transactionSheetVM.transactions.append(Transaction(category: categoryVM.getDefaultCategory(type: .expense), note: "", amount: nil, originWallet: defaultWallet, destinationWallet: defaultWallet))
                    } else if let firstWallet = walletVM.wallets.first?.id.uuidString {
                        transactionSheetVM.transactions.append(Transaction(category: categoryVM.getDefaultCategory(type: .expense), note: "", amount: nil, originWallet: firstWallet, destinationWallet: firstWallet))
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !vm.loading {
                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !vm.loading && isUpdate {
                        Button {
                            Task {
                                await vm.deleteShortcut(shortcutVM: shortcutVM)
                            }
                        } label: {
                            Text("Delete")
                        }
                        .foregroundColor(.red)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if vm.loading {
                        ProgressView()
                            .tint(tm.selectedTheme.tintColor)
                    } else {
                        Button {
                            Task {
                                vm.shortcut.transactions = transactionSheetVM.transactions
                                
                                if isUpdate {
                                    await vm.updateShortcut(shortcutVM: shortcutVM)
                                } else {
                                    await vm.createShortcut(shortcutVM: shortcutVM)
                                }
                            }
                        } label: {
                            Text(isUpdate ? "Update" : "Add")
                        }
                    }
                }
                
                ToolbarItem(placement: .keyboard) {
                    KeyboardToolbar()
                }
            }
            .onChange(of: vm.shouldSheetDismiss) { shouldSheetDismiss in
                if shouldSheetDismiss {
                    dismiss()
                }
            }
        }
        .analyticsScreen(name: self.pageTitle, class: self.pageTitle)
    }
}

struct ShortcutSheetView_Previews: PreviewProvider {
    static var previews: some View {
        ShortcutSheetView(shortcut: Shortcut(name: "", image: "house", color: defaultColors.blue.rawValue, transactions: [.init(category: "", originWallet: "", destinationWallet: "")]))
            .withPreviewEnvironmentObjects()
    }
}
