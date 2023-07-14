//
//  HomeView.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 02/10/22.
//

import SwiftUI
import WidgetKit
import FirebaseAnalytics
import FirebaseCrashlytics
import LogRocket
import Bugsnag
import Mixpanel

struct HomeView: View {
    @Environment(\.scenePhase) var scenePhase
    
    @AppStorage("userId", store: .grouped) var userId: String = ""
    @AppStorage("email", store: .grouped) var email: String?
    @AppStorage("name", store: .grouped) var name: String?
    @AppStorage("photoURL", store: .grouped) var photoURL: URL?
    
    @AppStorage("selectedUserId", store: .grouped) var selectedUserId: String = ""
    
    @AppStorage("doesUserExist", store: .grouped) var doesUserExist = true
    @AppStorage("hasShownOnboarding", store: .grouped) var hasShownOnboarding = false
    
    @EnvironmentObject var walletVM: WalletViewModel
    @EnvironmentObject var categoryVM: CategoryViewModel
    @EnvironmentObject var budgetVM: BudgetViewModel
    @EnvironmentObject var recurringVM: RecurringViewModel
    @EnvironmentObject var shortcutVM: ShortcutViewModel
    @EnvironmentObject var transactionVM: TransactionViewModel
    @EnvironmentObject var tm: ThemeManager
    
    @StateObject private var vm: HomeViewModel
    @StateObject var em = ErrorManager.shared
    
    private var allVMsLoaded: Bool {
        walletVM.loading || categoryVM.loading || shortcutVM.loading
    }
    
    init(){
        self._vm = StateObject(wrappedValue: HomeViewModel())
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                tm.selectedTheme.backgroundColor
                    .ignoresSafeArea()
                
                VStack {
                    if vm.selectedPage == .transactions {
                        TransactionView()
                    } else if vm.selectedPage == .wallets {
                        WalletView()
                    } else if vm.selectedPage == .reports {
                        ReportView()
                    } else {
                        BudgetView()
                    }
                    
                    Spacer()
                    
                    HStack {
                        ForEach(Page.allCases, id: \.self) { page in
                            Spacer()
                            
                            Button(action: {
                                if page == .transactionSheet {
                                    openTransactionSheet()
                                } else {
                                    vm.selectedPage = page
                                }
                            }, label: {
                                if page == .transactionSheet {
                                    Image(systemName: page.rawValue)
                                        .foregroundColor(.white)
                                        .font(.system(size: 22))
                                        .frame(width: 60, height: 60)
                                        .background(tm.selectedTheme.tintColor)
                                        .cornerRadius(30)
                                } else {
                                    Image(systemName: page.rawValue)
                                        .foregroundColor(vm.selectedPage == page ? tm.selectedTheme.tintColor : tm.selectedTheme.secondaryColor)
                                        .font(.system(size: 22))
                                }
                            })
                            .offset(y: -10)
                            .accessibilityIdentifier(page.rawValue)
                            
                            Spacer()
                        }
                        .offset(y: 10)
                    }
                    .frame(height: 60)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $vm.isSheetShown){
                TransactionSheetView(transactions: vm.newTransactions,
                                     isViewMode: false,
                                     isRecurringMode: false
                )
                .onDisappear {
                    vm.resetTransactions(wallets: walletVM.wallets, categoryVM: categoryVM)
                }
            }
            .sheet(isPresented: $vm.isOnboardingSheetShown, content: {
                OnboardingView()
            })
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    KeyboardToolbar()
                }
            }
            .onChange(of: scenePhase) { scenePhase in
                switch scenePhase {
                case .active:
                    AnalyticService.updateUserProperty(.lastSeen, value: Date())
                default:
                    break
                }
            }
            .onChange(of: doesUserExist) { doesUserExist in
                if !doesUserExist && !hasShownOnboarding && ConfigManager.shared.onboarding.showOnboarding {
                    vm.isOnboardingSheetShown = true
                    
                    hasShownOnboarding = true
                }
            }
        }
        .environmentObject(vm)
        .onAppear {
            Crashlytics.crashlytics().setUserID(userId)
            Analytics.setUserID(userId)
            
            SDK.identify(userID: userId, userInfo: [
              "name": name ?? "",
              "email": email ?? "",
            ])
            
            Bugsnag.setUser(userId, withEmail: email ?? "", andName: name ?? "")
            
            WidgetCenter.shared.getCurrentConfigurations { result in
                switch result {
                case .success(let info):
                    let widgets = info.map({ "\($0.kind) - \($0.family)"})
                    
                    AnalyticService.updateUserProperty(.widgets, value: widgets)
                case .failure(_):
                    break
                }
            }
            
            AnalyticService.updateUserProperty(.paywallConfig, value: ConfigManager.shared.paywallLimits)
            
            Crashlytics.crashlytics().setCustomValue(Locale.current.identifier, forKey: "locale")
            
            #if DEBUG
            Crashlytics.crashlytics().setCustomValue(true, forKey: "isDebug")
            #endif
        }
        .navigationViewStyle(.stack)
        .errorAlert(error: $em.serviceError)
        .errorAlert(error: $em.validationError)
        .errorAlert(error: $em.alertMessage)
        .alert(isPresented: $vm.isErrorAlertShown) {
            Alert(title: Text("No Wallets"), message: Text("Please add a wallet before adding a transaction or wait for it to load if you already have one."), dismissButton: .default(Text("OK")))
        }
        .onChange(of: allVMsLoaded, perform: { allVMsLoaded in
            guard !allVMsLoaded else { return }
            
            switch vm.isSheetQueued {
            case .none:
                break
            case .transaction(let slot):
                openTransactionSheet(slot: slot)
            }
        })
        .onOpenURL { url in
            guard url.scheme == "budgetify",
                  url.host == "transaction"
            else { return }
            
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let queryItems = components.queryItems,
               let slotNumberString = queryItems.first(where: { $0.name == "slot" })?.value,
               let slotNumber = Int(slotNumberString) {
                openTransactionSheet(slot: slotNumber)
            } else {
                openTransactionSheet()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .withPreviewEnvironmentObjects()
            .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
        
        HomeView()
            .withPreviewEnvironmentObjects()
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
    }
}

extension HomeView {
    func openTransactionSheet(slot: Int? = nil) {
        guard !vm.isSheetShown else { return }
        
        guard !allVMsLoaded else {
            vm.isSheetQueued = .transaction(slot: slot)
            return
        }
        
        vm.isSheetQueued = .none
        
        if let slot = slot,
           let shortcut = shortcutVM.shortcuts.first(where: { $0.slot == slot }),
           !shortcut.transactions.isEmpty {
            
            let shortcutTransactions = shortcut.transactions.map({ transaction in
                var mutableTransaction = transaction
                
                mutableTransaction.id = UUID()
                mutableTransaction.date = Date()
                
                return mutableTransaction
            })
            
            if shortcut.editBeforeAdding {
                vm.newTransactions = shortcutTransactions
                
                vm.isSheetShown.toggle()
            } else {
                Task {
                    await transactionVM.addTransactions(transactions: shortcutTransactions, walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM, recurringVM: recurringVM)
                }
            }
        } else if !walletVM.wallets.isEmpty && !categoryVM.categories.isEmpty {
            vm.resetTransactions(wallets: walletVM.wallets, categoryVM: categoryVM)
            
            vm.isSheetShown.toggle()
        } else {
            if walletVM.wallets.isEmpty {
                vm.isErrorAlertShown.toggle()
            }
            
            if categoryVM.categories.isEmpty {
                Task {
                    await categoryVM.getCategories()
                }
            }
        }
    }
}
