//
//  TransactionView.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 02/10/22.
//

import SwiftUI
import WidgetKit
import FirebaseAnalyticsSwift
import Charts

struct TransactionView: View {
    @AppStorage("currencyCode", store: .grouped) var currencyCode: String = ""
    @AppStorage("selectedPhotoURL", store: .grouped) var selectedPhotoURL: URL?
    
    @EnvironmentObject var vm: TransactionViewModel
    @EnvironmentObject var walletVM: WalletViewModel
    @EnvironmentObject var categoryVM: CategoryViewModel
    @EnvironmentObject var budgetVM: BudgetViewModel
    @EnvironmentObject var recurringVM: RecurringViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    
    @EnvironmentObject var tm: ThemeManager
    
    @ObservedObject var sm = SettingsManager.shared
    
    var body: some View {
        ZStack {
            tm.selectedTheme.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                    .unredacted()
                
                periodChanger
                    .unredacted()
                
                ScrollView(showsIndicators: false) {
                    amountView
                
                    TransactionListView(selectedTransaction: $vm.selectedTransaction, transactions: vm.transactions, onDelete: { transaction in
                        Task {
                            await vm.deleteTransaction(transaction: transaction, walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM)
                        }
                    })
                    
                    .padding(.top, -5)
                }
                .padding(.top, 8)
                .refreshable {
                    Task {
                        await vm.getTransactions(wallets: walletVM.wallets, categories: categoryVM.allCategories)
                    }
                }
            }
            .redacted(reason: vm.loading ? .placeholder : [])
            .sheet(item: $vm.selectedTransaction) { transaction in
                TransactionSheetView(transactions: [transaction],
                                     isViewMode: true,
                                     isRecurringMode: false
                )
            }
            .onAppear {
                let dueTransactions = recurringVM.checkDueTransactions()
                
                if !dueTransactions.isEmpty && !vm.isAddingRecurringTransactions {
                    Task {
                        vm.isAddingRecurringTransactions = true
                        
                        await vm.addTransactions(transactions: dueTransactions, walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM, recurringVM: recurringVM)
                        
                        vm.isAddingRecurringTransactions = false
                    }
                }
                
                budgetVM.checkDueDates(budgets: budgetVM.budgets)
                
                WidgetCenter.shared.reloadAllTimelines()
            }
            .onChange(of: vm.filterType) { value in
                vm.changePeriodType(type: value)
            }
            .onChange(of: vm.startDate) { _ in
                Task {
                    await vm.getTransactions(wallets: walletVM.wallets, categories: categoryVM.allCategories)
                }
            }
            .onChange(of: vm.endDate) { _ in
                Task {
                    await vm.getTransactions(wallets: walletVM.wallets, categories: categoryVM.allCategories)
                }
            }
            .sheet(isPresented: $vm.isSearchSheetShown) {
                SearchSheetView()
            }
            
        }
        .analyticsScreen(name: self.pageTitle, class: self.pageTitle)
    }
}

struct TransactionView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionView()
            .withPreviewEnvironmentObjects()
            .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
            
        TransactionView()
            .withPreviewEnvironmentObjects()
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
    }
}

extension TransactionView {
    var amountView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                Text("Expenses")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color("#929292"))
                    .unredacted()
                
                Text(vm.totalExpense.doubleValue.abbreviated.withCurrency(currency: sm.currencySymbols ? currencyCode.currencySymbol : currencyCode, color: tm.selectedTheme.tertiaryLabel))
                    .foregroundColor(.red)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .redacted(reason: sm.amountsVisible ? [] : .placeholder)
            }
            
            Spacer()
            
            VStack {
                Text(vm.totalChange.toString.withCurrency(currency: sm.currencySymbols ? currencyCode.currencySymbol : currencyCode, color: tm.selectedTheme.tertiaryLabel))
                    .font(.title.weight(.medium))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .redacted(reason: sm.amountsVisible ? [] : .placeholder)
            }
            .padding(.horizontal)
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("Income")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color("#929292"))
                    .unredacted()
                
                Text(vm.totalIncome.doubleValue.abbreviated.withCurrency(currency: sm.currencySymbols ? currencyCode.currencySymbol : currencyCode, color: tm.selectedTheme.tertiaryLabel))
                    .foregroundColor(.green)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .redacted(reason: sm.amountsVisible ? [] : .placeholder)
            }
        }
        .padding(.horizontal)
    }
    
    var header: some View {
        HStack {
            Text("Transactions")
                .font(.largeTitle)
                .fontWeight(.semibold)
            
            Spacer()
            
            let isSearchActive = vm.unfilteredTransactions != vm.filteredTransactions
            
            Button(action: {
                vm.isSearchSheetShown.toggle()
            }, label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 17, weight: isSearchActive ? .semibold : .regular))
            })
            .foregroundColor(isSearchActive ? tm.selectedTheme.tintColor : tm.selectedTheme.primaryColor)
            
            Menu {
                Picker("", selection: $vm.filterType) {
                    ForEach(FilterType.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
            } label: {
                Image(systemName: "calendar")
            }
            
            
            NavigationLink(destination: RecurringView()) {
                ZStack {
                    Image(systemName: "arrow.2.squarepath")
                    
                    if recurringVM.countUpcomingTransactions() > 0 && sm.recurringBadge {
                        Text("\(recurringVM.countUpcomingTransactions())")
                            .foregroundColor(.white)
                            .font(.caption2)
                            .minimumScaleFactor(0.5)
                            .background(
                                Circle()
                                    .foregroundColor(.red)
                                    .frame(width: 15, height: 15)
                            )
                            .offset(x: 7.5, y: -7.5)
                            .frame(width: 12.5, height: 12.5)
                    }
                    
                }
            }
            
            
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
    
    var periodChanger: some View {
        HStack {
            Button(action: {
                vm.changePeriod(change: .previous)
            }, label: {
                Image(systemName: "chevron.left")
            })
            
            Spacer()
            
            if vm.filterType != .custom {
                
                Text(vm.filterType == .yearly ?
                     vm.startDate.getYearString
                     :
                        vm.filterType == .monthly ?
                     vm.startDate.getMonthString
                     : vm.filterType == .daily ?
                     vm.startDate.toString
                     :
                        "\(vm.startDate.getDateAndMonthString) - \(vm.endDate.getDateAndMonthString)"
                )
                .font(.system(size: 16))
                .fontWeight(.medium)
                .foregroundColor(tm.selectedTheme.secondaryColor)
                .padding(.horizontal, 5)
            } else {
                HStack(spacing: 0) {
                    CustomDatePicker(date: $vm.startDate)
                    Spacer()
                    Rectangle()
                        .foregroundColor(tm.selectedTheme.secondaryColor)
                        .frame(width: 10, height: 1)
                        .padding(.horizontal, 10)
                    Spacer()
                    CustomDatePicker(date: $vm.endDate, alignment: .forceRightToLeft)
                }
            }
            
            Spacer()
            
            Button(action: {
                vm.changePeriod(change: .next)
            }, label: {
                Image(systemName: "chevron.right")
            })
        }
        .frame(height: 40)
        .padding(.horizontal)
        .foregroundColor(tm.selectedTheme.primaryColor)
    }
}
