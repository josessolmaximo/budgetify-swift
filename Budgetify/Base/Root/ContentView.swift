//
//  ContentView.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 01/10/22.
//

import SwiftUI
import WidgetKit
import FirebaseCrashlytics

struct ContentView: View {
    @AppStorage("userId", store: .grouped) var userId: String?
    @AppStorage("email", store: .grouped) var email: String?
    @AppStorage("name", store: .grouped) var name: String?
    @AppStorage("photoURL", store: .grouped) var photoURL: URL?
    
    @AppStorage("selectedUserId", store: .grouped) var selectedUserId: String?
    @AppStorage("currencyCode", store: .grouped) var currencyCode: String?
    
    @StateObject var sharingVM: SharingViewModel
    @StateObject var transactionVM: TransactionViewModel
    @StateObject var walletVM: WalletViewModel
    @StateObject var categoryVM: CategoryViewModel
    @StateObject var budgetVM: BudgetViewModel
    @StateObject var recurringVM: RecurringViewModel
    @StateObject var accountVM: AccountViewModel
    @StateObject var loginVM: LoginViewModel
    @StateObject var shortcutVM: ShortcutViewModel
    
    @ObservedObject var em = ErrorManager.shared
    
    let isUITesting: Bool
    
    init(){
        isUITesting = UITestingHelper.isUITesting
        
        let transactionService: TransactionServiceProtocol = isUITesting ? MockTransactionService() : TransactionService()
        let walletService: WalletServiceProtocol = isUITesting ? MockWalletService() : WalletService()
        let budgetService: BudgetServiceProtocol = isUITesting ? MockBudgetService() : BudgetService()
        let categoryService: CategoryServiceProtocol = isUITesting ? MockCategoryService() : CategoryService()
        let recurringService: RecurringServiceProtocol = isUITesting ? MockRecurringService() : RecurringService()
        let loginService: LoginServiceProtocol = isUITesting ? MockLoginService() : LoginService()
        let imageService: ImageServiceProtocol = isUITesting ? MockImageService() : ImageService()
        let shortcutService: ShortcutServiceProtocol = isUITesting ? MockShortcutService() : ShortcutService()
        
        _sharingVM = StateObject(wrappedValue: SharingViewModel(sharingService: SharingService()))
        _transactionVM = StateObject(wrappedValue: TransactionViewModel(transactionService: transactionService, walletService: walletService, budgetService: budgetService, imageService: imageService))
        _walletVM = StateObject(wrappedValue: WalletViewModel(walletService: walletService))
        _categoryVM = StateObject(wrappedValue: CategoryViewModel(categoryService: categoryService))
        _budgetVM = StateObject(wrappedValue: BudgetViewModel(budgetService: budgetService))
        _recurringVM = StateObject(wrappedValue: RecurringViewModel(recurringService: recurringService))
        _accountVM = StateObject(wrappedValue: AccountViewModel(loginService: loginService))
        _loginVM = StateObject(wrappedValue: LoginViewModel(loginService: loginService))
        _shortcutVM = StateObject(wrappedValue: ShortcutViewModel(service: shortcutService))
    }
    
    func setup(){
        Task {
            await transactionVM.getTransactions(wallets: [], categories: [])
            await walletVM.getWallets()
            await budgetVM.getBudgets()
            await categoryVM.getCategories()
            await categoryVM.getCategoryOrder()
            await recurringVM.getTransactions()
            await sharingVM.getData()
            await shortcutVM.getShortcuts()
            await PremiumManager.shared.getPremium(id: selectedUserId ?? "")
        }
        
        AnalyticService.updateUserProperty(.appVersion, value: "\(Bundle.main.releaseVersionNumber) (\(Bundle.main.buildVersionNumber))")
        
        if let userId = userId,
           let email = email {
            AnalyticService.updateUserData(
                User(id: userId,
                     email: email,
                     displayName: name ?? "",
                     photoURL: photoURL?.absoluteString ?? "")
                )
        }
    }
    
    var body: some View {
        ZStack {
            if let _ = userId,
               let _ = selectedUserId
            {
                HomeView()
                    .environmentObject(transactionVM)
                    .environmentObject(walletVM)
                    .environmentObject(budgetVM)
                    .environmentObject(categoryVM)
                    .environmentObject(recurringVM)
                    .environmentObject(accountVM)
                    .environmentObject(sharingVM)
                    .environmentObject(shortcutVM)
                    .onAppear {
                        setup()
                    }
            } else {
                LoginView()
                    .environmentObject(loginVM)
            }
        }
        .onAppear {
            if currencyCode == nil {
                currencyCode = Locale.current.currencyCode
            }
            
            ConfigManager.shared.checkMinimumVersion(current: Bundle.main.releaseVersionNumber, minimum: ConfigManager.shared.minimumVersion)
        }
        .onChange(of: selectedUserId) { id in
            if id != nil {
                setup()
                
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
        .onChange(of: userId) { id in
            if id != nil {
                setup()
            }
        }
        .alert("A New Version is Available", isPresented: $em.versionError, actions: {
            Button("Update") {
                if let url = URL(string: "https://apps.apple.com/us/app/budgetify-expense-tracker/id6443894407") {
                    UIApplication.shared.open(url)
                }
                
                em.versionError = true
            }
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
