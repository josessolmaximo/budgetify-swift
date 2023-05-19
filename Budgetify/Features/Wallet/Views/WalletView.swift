//
//  WalletView.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 07/10/22.
//

import SwiftUI
import FirebaseAnalyticsSwift

struct WalletView: View {
    @EnvironmentObject var vm: WalletViewModel
    @EnvironmentObject var transactionVM: TransactionViewModel
    
    @EnvironmentObject var tm: ThemeManager
    
    @AppStorage("currencyCode", store: .grouped) var currencyCode: String = ""
    @AppStorage("selectedPhotoURL", store: .grouped) var selectedPhotoURL: URL?
    
    @ObservedObject var sm = SettingsManager.shared
    
    var body: some View {
        ZStack {
            tm.selectedTheme.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 10) {
                header
                    .unredacted()
                
                ScrollView {
                    VStack(spacing: 5) {
                        VStack {
                            HStack(spacing: 5) {
                                Text("Net Worth")
                                    .font(.title2.weight(.medium))
                                
                                Spacer()
                                
                                Text(sm.currencySymbols ? currencyCode.currencySymbol : currencyCode)
                                    .foregroundColor(tm.selectedTheme.tertiaryLabel)
                                
                                
                                AmountTextView(vm.wallets.filter({ !$0.isExcluded }).map({ $0.amount }).reduce(0, +).toString)
                                    .font(.title.weight(.medium))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.9)
                            }
                            .font(.title)
                        }
                        .padding(.horizontal)
                        
                        ForEach(vm.wallets.filter({ !$0.amount.isZero || !sm.hideEmptyWallets })) { wallet in
                            walletRow(wallet: wallet)
                                .padding(.vertical, 5)
                        }
                    }
                }
                
                Spacer()
            }
            .redacted(reason: vm.loading ? .placeholder : [])
            .sheet(isPresented: $vm.isSheetShown) {
                WalletSheetView(
                    wallet: Wallet(name: "", amount: 0, image: "custom.wallet", order: (vm.wallets.map({$0.order}).max() ?? 0) + 1),
                    parentVM: vm)
                .accessibilityIdentifier("walletSheet")
            }
            .refreshable {
                Task {
                    await vm.getWallets()
                }
            }
        }
        .analyticsScreen(name: self.pageTitle, class: self.pageTitle)
    }
}

struct WalletView_Previews: PreviewProvider {
    static var previews: some View {
        WalletView()
            .environmentObject(WalletViewModel(walletService: MockWalletService()))
            .environmentObject(TransactionViewModel(
                transactionService: MockTransactionService(),
                walletService: MockWalletService(),
                budgetService: MockBudgetService(),
                imageService: MockImageService()
            ))
            .environmentObject(ThemeManager())
    }
}

extension WalletView {
    var header: some View {
        HStack {
            Text("Wallets")
                .font(.largeTitle)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button(action: {
                vm.isSheetShown = true
            }, label: {
                Image(systemName: "plus")
                
            })
            .accessibilityIdentifier("createButton")
            
            Rectangle()
                .foregroundColor(Color(uiColor: .tertiaryLabel))
                .frame(width: 1, height: 20)
                
            NavigationLink(destination: AccountView()) {
                ProfilePictureView(photoURL: selectedPhotoURL, dimensions: 25)
            }
        }
        .padding(.horizontal)
        .foregroundColor(tm.selectedTheme.primaryColor)
    }
    
    func walletRow(wallet: Wallet) -> some View {
        NavigationLink(destination: WalletDetailView(wallet: wallet, parentVM: vm)) {
            HStack {
                
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        CustomIconView(imageName: wallet.image)
                        
                        Text(wallet.name)
                            .fontWeight(.medium)
                            .foregroundColor(tm.selectedTheme.secondaryColor)
                    }
                    
                    HStack {
                        HStack(spacing: 5) {
                            Text(sm.currencySymbols ? currencyCode.currencySymbol : currencyCode)
                                .foregroundColor(tm.selectedTheme.tertiaryLabel)
                            
                            AmountTextView(wallet.amount.toString)
                                .font(.title.weight(.medium))
                        }
                        .font(.title)
                            
                        Spacer()
                        
                        VStack {
                            Spacer()
                            
                            if let targetAmount = wallet.targetAmount, wallet.type == .target {
                                AmountTextView("\(targetAmount.toString)")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(tm.selectedTheme.secondaryColor)
                                    
                            }
                        }
                    }
                    
                    if let targetAmount = wallet.targetAmount, wallet.type == .target {
                        ProgressView(value: wallet.amount.floatValue/targetAmount.floatValue)
                            .padding(.bottom, 10)
                            .tint(tm.selectedTheme.primaryColor)
                    }
                }
            }
            
            .padding(.horizontal)
        }
        .accessibilityIdentifier(wallet.id.uuidString)
        .foregroundColor(tm.selectedTheme.primaryColor)
    }
}
