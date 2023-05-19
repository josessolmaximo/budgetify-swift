//
//  SettingsView.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 19/03/23.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var transactionVM: TransactionViewModel
    @EnvironmentObject var walletVM: WalletViewModel
    @EnvironmentObject var categoryVM: CategoryViewModel
    @EnvironmentObject var budgetVM: BudgetViewModel
    @EnvironmentObject var sharingVM: SharingViewModel
    @EnvironmentObject var recurringVM: RecurringViewModel
    
    @EnvironmentObject var accountVM: AccountViewModel
    @EnvironmentObject var tm: ThemeManager
    
    @StateObject var vm = SettingsViewModel()
    
    @ObservedObject var sm = SettingsManager.shared
    
    @State private var isCacheAlertVisible = false
    @State private var isEraseDataAlertVisible = false
    @State private var isDeletingAccountAlertVisible = false
    
    @State private var cacheLabel = "\(ByteCountFormatter.string(fromByteCount: Int64(URLCache.shared.currentDiskUsage), countStyle: .file))"
    
    var body: some View {
        ZStack {
            tm.selectedTheme.backgroundColor
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 10) {
                    Group {
                        VStack(spacing: 10) {
                            HStack {
                                Text("Appearance")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(tm.selectedTheme.secondaryLabel)
                                    .padding(.leading, 10)
                                Spacer()
                            }
                            
                            VStack {
                                Spacer()
                                    .frame(height: 5)
                                
                                toggleRow(
                                    title: "Amounts Visible",
                                    image: "eye.slash",
                                    toggle: $sm.amountsVisible
                                )
                                
                                toggleRow(
                                    title: "Recurring Badge",
                                    image: "arrow.2.squarepath",
                                    toggle: $sm.recurringBadge
                                )
                                
                                toggleRow(
                                    title: "Currency Symbols",
                                    image: "dollarsign",
                                    toggle: $sm.currencySymbols
                                )
                                
                                toggleRow(
                                    title: "Hide Empty Wallets",
                                    image: "circle.slash",
                                    toggle: $sm.hideEmptyWallets
                                )
                                
                                stepperRow(
                                    title: "Decimal Points",
                                    image: "centsign",
                                    selection: $sm.decimalPoints,
                                    range: 0...5
                                )
                                
                                menuRow(
                                    title: "Line Chart",
                                    image: "chart.xyaxis.line",
                                    selection: $sm.lineGraphStyle,
                                    selected: sm.lineGraphStyle.rawValue,
                                    data: LineGraphStyle.allCases
                                )
                                
                                Spacer()
                                    .frame(height: 5)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor(Color(uiColor: colorScheme == .light ? .systemGray6 : .systemGray5))
                            )
                        }
                        
                        VStack(spacing: 10) {
                            HStack {
                                Text("About")
                                    .foregroundColor(tm.selectedTheme.secondaryLabel)
                                    .font(.system(size: 14, weight: .medium))
                                    .padding(.leading, 10)
                                Spacer()
                            }
                            
                            VStack {
                                Spacer()
                                    .frame(height: 5)
                                
                                actionRow(title: "Privacy Policy", image: "hand.raised") {
                                    if let url = URL(string: ConfigManager.shared.privacyPolicyLink) {
                                        UIApplication.shared.open(url)
                                    }
                                }
                                
                                actionRow(title: "Terms of Use", image: "doc.plaintext") {
                                    if let url = URL(string: ConfigManager.shared.termsOfUseLink) {
                                        UIApplication.shared.open(url)
                                    }
                                }
                                
                                actionRow(title: "Developer Website", image: "globe") {
                                    if let url = URL(string: ConfigManager.shared.developerWebsiteLink) {
                                        UIApplication.shared.open(url)
                                    }
                                }
                                
                                actionRow(title: "Share With Friends", image: "square.and.arrow.up") {
                                    guard let url = URL(string: "https://apps.apple.com/us/app/budgetify-expense-tracker/id6443894407") else { return }
                                    
                                    let activityView = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                                    
                                    UIApplication.shared.windows.first?.rootViewController?.present(activityView, animated: true, completion: nil)
                                }
                                
                                Spacer()
                                    .frame(height: 5)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor(Color(uiColor: colorScheme == .light ? .systemGray6 : .systemGray5))
                            )
                        }
                        
                        VStack(spacing: 10) {
                            HStack {
                                Text("Storage")
                                    .foregroundColor(tm.selectedTheme.secondaryLabel)
                                    .font(.system(size: 14, weight: .medium))
                                    .padding(.leading, 10)
                                Spacer()
                            }
                            
                            VStack {
                                Spacer()
                                    .frame(height: 5)
                                
                                actionRow(title: "Cache Size", secondaryLabel: cacheLabel, image: "externaldrive") {
                                    isCacheAlertVisible.toggle()
                                }
                                
                                Spacer()
                                    .frame(height: 5)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor(Color(uiColor: colorScheme == .light ? .systemGray6 : .systemGray5))
                            )
                        }
                        
                        VStack(spacing: 10) {
                            HStack {
                                Text("Data")
                                    .foregroundColor(tm.selectedTheme.secondaryLabel)
                                    .font(.system(size: 14, weight: .medium))
                                    .padding(.leading, 10)
                                Spacer()
                            }
                            
                            VStack {
                                Spacer()
                                    .frame(height: 5)
                                
                                actionRow(title: "Export to CSV", image: "square.and.arrow.up") {
                                    Task {
                                        await vm.exportCSV(transactionVM: transactionVM, categoryVM: categoryVM, walletVM: walletVM)
                                    }
                                }
                                
                                actionRow(title: "Erase Data", role: .destructive, image: "xmark.bin", isLoading: accountVM.isErasingData) {
                                    isEraseDataAlertVisible.toggle()
                                }
                                
                                actionRow(title: "Delete Account", role: .destructive, image: "trash", isLoading: accountVM.isDeletingAccount) {
                                    isDeletingAccountAlertVisible.toggle()
                                }
                                
                                Spacer()
                                    .frame(height: 5)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor(Color(uiColor: colorScheme == .light ? .systemGray6 : .systemGray5))
                            )
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .modifier(CustomBackButtonModifier(dismiss: dismiss))
                .analyticsScreen(name: self.pageTitle, class: self.pageTitle)
                .onAppear {
                    sm.readStorage()
                }
                .onDisappear {
                    sm.setStorage()
                }
                .alert("Clear Cache", isPresented: $isCacheAlertVisible) {
                    Button("Cancel", role: .cancel) { }
                    Button("Clear", role: .destructive) {
                        URLCache.shared.removeAllCachedResponses()
                        cacheLabel = "0 KB"
                    }
                }
                .deleteTextFieldAlert(isPresented: $isEraseDataAlertVisible, message: "Erases all data and start fresh with all initial categories. This won't delete your premium info.") { input in
                    if input == "DELETE" {
                        Task {
                            await accountVM.eraseData {
                                Task {
                                    await categoryVM.getCategories()
                                    await walletVM.getWallets()
                                    await transactionVM.getTransactions(wallets: walletVM.wallets, categories: categoryVM.allCategories)
                                    await budgetVM.getBudgets()
                                    await recurringVM.getTransactions()
                                    await sharingVM.getData()
                                }
                            }
                        }
                    }
                }
                .deleteTextFieldAlert(isPresented: $isDeletingAccountAlertVisible, message: "Erases all data in your account, including your premium info. Cancel your subcription manually after deleting your account") { input in
                    if input == "DELETE" {
                        Task {
                            await accountVM.deleteAccount(dismiss: dismiss)
                        }
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .withPreviewEnvironmentObjects()
            .preferredColorScheme(.dark)
        
        SettingsView()
            .withPreviewEnvironmentObjects()
            .preferredColorScheme(.light)
    }
}

extension SettingsView {
    func toggleRow(title: String, image: String, toggle: Binding<Bool>) -> some View {
        HStack {
            CustomIconView(imageName: image, dimensions: 20)
                .padding(5)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(Color(uiColor: .systemBackground))
                )
            
            Text(title)
                .fontWeight(.medium)
            
            Spacer()
            
            Toggle("", isOn: toggle)
                .labelsHidden()
        }
        .padding(5)
        .padding(.horizontal, 5)
    }
    
    func menuRow<T: Hashable & RawRepresentable>(title: String, image: String, selection: Binding<T>, selected: String, data: [T]) -> some View {
        HStack {
            CustomIconView(imageName: image, dimensions: 20)
                .padding(5)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(Color(uiColor: .systemBackground))
                )
            
            Text(title)
                .fontWeight(.medium)
            
            Spacer()
            
            Menu {
                Picker("", selection: selection) {
                    ForEach(data, id: \.self) { option in
                        Text("\(option.rawValue as? String ?? "")")
                            .tag(option)
                    }
                }
            } label: {
                Text(selected)
                    .font(.system(size: 15))
                    .fontWeight(.medium)
                    .foregroundColor(tm.selectedTheme.primaryLabel)
            }
        }
        .padding(5)
        .padding(.horizontal, 5)
    }
    
    func stepperRow(title: String, image: String, selection: Binding<Int>, range: ClosedRange<Int>) -> some View {
        HStack {
            CustomIconView(imageName: image, dimensions: 20)
                .padding(5)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(Color(uiColor: .systemBackground))
                )
            
            Text(title)
                .fontWeight(.medium)
            
            Spacer()
            
            Text("\(selection.wrappedValue)")
                .font(.system(size: 15))
                .fontWeight(.medium)
                .padding(.trailing, 5)
            
            Stepper("", value: selection, in: range, step: 1)
                .font(.system(size: 15, weight: .semibold))
                .labelsHidden()
        }
        .padding(5)
        .padding(.horizontal, 5)
    }
    
    func actionRow(title: String, secondaryLabel: String? = nil, role: ButtonRole = .cancel, image: String, isLoading: Bool = false,  action: @escaping (() -> Void)) -> some View {
        HStack {
            CustomIconView(imageName: image, dimensions: 20)
                .padding(5)
                .foregroundColor(role == .cancel ? tm.selectedTheme.primaryColor : .red)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(tm.selectedTheme.backgroundColor)
//                        .foregroundColor(role == .cancel ? tm.selectedTheme.backgroundColor : .red)
//                        .foregroundColor(Color(uiColor: .systemBackground))
                )
            
            Button {
                action()
            } label: {
                HStack {
                    Text(title)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    if let secondaryLabel = secondaryLabel {
                        Text(secondaryLabel)
                            .fontWeight(.medium)
                            .foregroundColor(tm.selectedTheme.secondaryLabel)
                    }
                    
                    if isLoading {
                        ProgressView()
                            .tint(role == .cancel ? tm.selectedTheme.tintColor : .red)
                    } else {
                        CustomIconView(imageName: "chevron.right", dimensions: 15)
                    }
                }
            }
            .foregroundColor(role == .cancel ? tm.selectedTheme.primaryLabel : .red)
        }
        .padding(5)
        .padding(.horizontal, 5)
    }
    
}
