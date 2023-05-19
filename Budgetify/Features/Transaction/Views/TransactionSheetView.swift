//
//  TransactionSheet.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 17/11/22.
//

import SwiftUI
import FirebaseAnalyticsSwift

struct TransactionSheetView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var budgetVM: BudgetViewModel
    
    @StateObject var vm: TransactionSheetViewModel
    
    @EnvironmentObject var walletVM: WalletViewModel
    @EnvironmentObject var categoryVM: CategoryViewModel
    @EnvironmentObject var transactionVM: TransactionViewModel
    @EnvironmentObject var recurringVM: RecurringViewModel
    
    @EnvironmentObject var tm: ThemeManager
    
    @FocusState var focusedField: FocusedField?
    
    @StateObject var em = ErrorManager.shared
    
    init(transactions: [Transaction],
         isViewMode: Bool,
         isRecurringMode: Bool
    ) {
        self._vm = StateObject(wrappedValue: TransactionSheetViewModel(transactions: transactions, isViewMode: isViewMode, isRecurringMode: isRecurringMode))
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { proxy in
                let fitsWidth = proxy.size.width - 40 >= 350
                
                ZStack {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach($vm.transactions) { $transaction in
                                TransactionItemView(transaction: $transaction, mode: vm.doesTransactionExist ? .create : vm.isRecurringMode ? .recurring : .update)
                                    .padding(.horizontal, fitsWidth ? 18 : (proxy.size.width - 351) / 2)
                                    .environmentObject(vm)
                                    .allowsHitTesting(vm.canDismiss)
                            }
                        }
                        
                        if !vm.doesTransactionExist {
                            HStack {
                                addButton
                            }
                        }
                    }
                    
                    if !vm.canDismiss {
                        viewBlocker
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    ZStack {
                        if !vm.loading {
                            Button("Cancel") {
                                if vm.canDismiss {
                                    dismiss()
                                }
                            }
                            .foregroundColor(tm.selectedTheme.tintColor)
                        }
                        
                        if !vm.canDismiss {
                            viewBlocker
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    ZStack {
                        if vm.doesTransactionExist && !vm.loading {
                            Button(role: .destructive) {
                                Task {
                                    if !vm.isRecurringMode {
                                        await vm.deleteTransaction(transactionVM: transactionVM, walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM)
                                    } else {
                                        await vm.deleteRecurringTransaction(recurringVM: recurringVM)
                                    }
                                }
                            } label: {
                                Text("Delete")
                            }
                            .foregroundColor(.red)
                        }
                        
                        if !vm.canDismiss {
                            viewBlocker
                        }
                    }
                }
                
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    ZStack {
                        if vm.loading {
                            ProgressView()
                                .tint(tm.selectedTheme.tintColor)
                        } else {
                            Button(vm.doesTransactionExist ? "Save" : "Add") {
                                if !vm.doesTransactionExist {
                                    Task {
                                        await vm.addTransactions(transactionVM: transactionVM,
                                                                 walletVM: walletVM,
                                                                 budgetVM: budgetVM,
                                                                 recurringVM: recurringVM,
                                                                 categoryVM: categoryVM
                                        )
                                    }
                                } else {
                                    Task {
                                        await vm.updateTransactions(transactionVM: transactionVM,
                                                                    recurringVM: recurringVM,
                                                                    walletVM: walletVM,
                                                                    budgetVM: budgetVM,
                                                                    categoryVM: categoryVM
                                        )
                                    }
                                }
                            }
                            .foregroundColor(tm.selectedTheme.tintColor)
                        }
                        
                        if !vm.canDismiss {
                            viewBlocker
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    KeyboardToolbar()
                }
            }
        }
        .analyticsScreen(name: self.pageTitle, class: self.pageTitle)
        .errorAlert(error: $em.serviceError)
        .sheet(isPresented: $em.premiumError, content: {
            PremiumSheetView()
        })
        .onChange(of: vm.shouldSheetDismiss) { value in
            if value && vm.canDismiss {
                dismiss()
            }
        }
    }
}

struct TransactionSheetView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionSheetView(transactions: [
            Transaction(category: "", date: Date(), amount: 515597, originWallet: defaultWallets.randomElement()!.id.uuidString, destinationWallet: defaultWallets.randomElement()!.id.uuidString)
        ], isViewMode: false, isRecurringMode: false)
            .withPreviewEnvironmentObjects()
            .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
        
        TransactionSheetView(transactions: [
            Transaction(category: "", date: Date(), amount: 515597, originWallet: defaultWallets.randomElement()!.id.uuidString, destinationWallet: defaultWallets.randomElement()!.id.uuidString)
        ], isViewMode: false, isRecurringMode: false)
            .withPreviewEnvironmentObjects()
            .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro Max"))
    }
}

extension TransactionSheetView {
    var addButton: some View {
        Button(action: {
            if PremiumManager.shared.isPremium || vm.transactions.count < ConfigManager.shared.paywallLimits["transactions"]! {
                if let defaultWallet = walletVM.wallets.first(where: { $0.isDefault })?.id.uuidString {
                    vm.transactions.append(Transaction(category: categoryVM.getDefaultCategory(type: .expense), note: "", amount: nil, originWallet: defaultWallet, destinationWallet: defaultWallet))
                } else if let firstWallet = walletVM.wallets.first?.id.uuidString {
                    vm.transactions.append(Transaction(category: categoryVM.getDefaultCategory(type: .expense), note: "", amount: nil, originWallet: firstWallet, destinationWallet: firstWallet))
                }
            } else {
                ErrorManager.shared.premiumError = true
            }
        }, label: {
            Image(systemName: "plus")
            Text("Add Transaction")
        })
        .padding(.bottom, 20)
    }
    
    var viewBlocker: some View {
        Color.clear
            .contentShape(Rectangle())
            .onTapGesture {
                vm.canDismiss = true
            }
    }
}
