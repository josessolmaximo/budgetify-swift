//
//  AddWalletSheet.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 11/10/22.
//

import SwiftUI
import FirebaseAnalyticsSwift

struct WalletSheetView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var vm: WalletSheetViewModel
    
    @EnvironmentObject var tm: ThemeManager
    
    @ObservedObject var em = ErrorManager.shared
    @ObservedObject var sm = SettingsManager.shared
    
    @AppStorage("currencyCode", store: .grouped) var currencyCode: String = ""
    
    init(wallet: Wallet, parentVM: WalletViewModel) {
        self._vm = StateObject(wrappedValue: WalletSheetViewModel(wallet: wallet, parentVM: parentVM))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                Picker("", selection: $vm.wallet.type) {
                    ForEach(WalletType.allCases, id: \.rawValue) {
                        Text($0.rawValue)
                            .tag($0)
                            .accessibilityIdentifier($0.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                amount
                
                nameRow
                
                HStack {
                    Text("Exclude from Net Worth")
                    Spacer()
                    Checkbox(isChecked: $vm.wallet.isExcluded)
                }
                .padding(.horizontal)
                
                HStack {
                    Text("Default Wallet")
                    
                    Spacer()
                    
                    Checkbox(isChecked: $vm.wallet.isDefault)
                }
                .padding(.horizontal)
                
                let walletExists = vm.parentVM.wallets.contains(where: {$0.id == vm.wallet.id})
                if vm.wallet.type == .target {
                    HStack(spacing: 5) {
                        Text("Target Amount")
                        
                        TextField("0", value: $vm.wallet.targetAmount, format : .number)
                            .labelsHidden()
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(tm.selectedTheme.primaryLabel)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .accessibilityIdentifier("targetTextfield")
                    }
                    .padding(.horizontal)
                }
                
                if walletExists {
                    HStack(spacing: 5) {
                        Text("Order")
                        
                        TextField("0", value: $vm.wallet.order, format : .number)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(tm.selectedTheme.primaryLabel)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    .padding(.horizontal)
                    
                    InfoBox(text: "Editing or deleting this wallet will change previous transactions.")
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $vm.isDeleteAlertShown, content: {
                Alert(
                    title: Text("Delete Wallet"),
                    message: Text("Deleting this wallet will remove references from existing transactions"),
                    primaryButton: .destructive(Text("Delete"), action: {
                        Task {
                            await vm.deleteWallet(wallet: vm.wallet)
                        }
                    }),
                    secondaryButton: .cancel(Text("Cancel")))
            })
            .alert("Validation Error", isPresented: $vm.isErrorAlertShown) {
                Button("OK") {
                    vm.isErrorAlertShown = false
                }
            } message: {
                Text(vm.errorAlertMessage)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !vm.loading {
                        Button("Cancel") {
                            dismiss()
                        }
                        .accessibilityIdentifier("cancelButton")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if vm.parentVM.wallets.contains(where: {$0.id == vm.wallet.id}) && !vm.loading {
                        Button(role: .destructive) {
                            vm.isDeleteAlertShown.toggle()
                        } label: {
                            Text("Delete")
                        }
                        .foregroundColor(.red)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    let isUpdate = vm.parentVM.wallets.contains(where: { $0.id == vm.wallet.id })
                    
                    if vm.loading {
                        ProgressView()
                            .tint(tm.selectedTheme.tintColor)
                            .accessibilityIdentifier("loadingIndicator")
                    } else {
                        Button(isUpdate ? "Save" : "Add") {
                            Task {
                                if isUpdate {
                                    await vm.updateWallet(wallet: vm.wallet)
                                } else {
                                    if PremiumManager.shared.isPremium || vm.parentVM.wallets.count < ConfigManager.shared.paywallLimits["wallets"]! {
                                        await vm.createWallet(wallet: vm.wallet)
                                    } else {
                                        ErrorManager.shared.premiumError = true
                                    }
                                }
                            }
                        }
                        .accessibilityIdentifier("createButton")
                    }
                }
                
                ToolbarItem(placement: .keyboard) {
                    KeyboardToolbar()
                }
            }
        }
        .onChange(of: vm.wallet.type, perform: { type in
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            
            if type == .debit {
                vm.wallet.amount = abs(vm.wallet.amount)
            } else if type == .credit {
                vm.wallet.amount = -vm.wallet.amount
            }
        })
        .onChange(of: vm.shouldSheetDismiss) { value in
            if value {
                dismiss()
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

struct WalletSheetView_Previews: PreviewProvider {
    static var previews: some View {
        let walletService = MockWalletService()
        let parentVM = WalletViewModel(walletService: walletService)
        WalletSheetView(wallet: defaultWallets.first!, parentVM: parentVM)
            .withPreviewEnvironmentObjects()
    }
}

extension WalletSheetView {
    var amount: some View {
        HStack {
            Text(sm.currencySymbols ? currencyCode.currencySymbol : currencyCode)
                .foregroundColor(tm.selectedTheme.tertiaryLabel)
            
            let walletExists = vm.parentVM.wallets.contains(where: {$0.id == vm.wallet.id})
            
            TextField("0", value: $vm.wallet.amount, format: .number)
                .foregroundColor(tm.selectedTheme.primaryLabel)
                .font(.system(size: 44, weight: .semibold))
                .keyboardType(.decimalPad)
                .accessibilityIdentifier("amountTextfield")
                .redacted(reason: sm.amountsVisible || !walletExists ? [] : .placeholder)
                .disabled(walletExists && !sm.amountsVisible)
        }
        .font(.system(size: 44))
        .padding(.horizontal)
    }
    
    var nameRow: some View {
        HStack {
            IconPickerField(text: $vm.wallet.name, image: $vm.wallet.image)
            
            Button {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                
                vm.wallet.amount.negate()
            } label: {
                Image(systemName: "plusminus")
            }
            .foregroundColor(tm.selectedTheme.primaryColor)
            .padding(.trailing, 2.5)
        }
        .padding(.horizontal)
    }
}


