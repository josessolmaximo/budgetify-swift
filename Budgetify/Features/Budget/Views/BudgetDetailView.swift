//
//  BudgetDetailView.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 01/12/22.
//

import SwiftUI
import OrderedCollections
import FirebaseAnalyticsSwift

struct BudgetDetailView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var transactionVM: TransactionViewModel
    @EnvironmentObject var budgetVM: BudgetViewModel
    @EnvironmentObject var walletVM: WalletViewModel
    @EnvironmentObject var categoryVM: CategoryViewModel
    @EnvironmentObject var tm: ThemeManager
    
    @StateObject var vm: BudgetDetailViewModel
    
    @AppStorage("currencyCode", store: .grouped) var currencyCode: String = ""
    
    @ObservedObject var sm = SettingsManager.shared
    
    let budget: Budget
    let budgetHistory: BudgetHistory
    
    init(budget: Budget, parentVM: BudgetSheetProtocol) {
        self._vm = StateObject(wrappedValue: BudgetDetailViewModel(budget: budget, parentVM: parentVM))
        self.budget = budget
        self.budgetHistory = .init(startDate: budget.startDate, endDate: budget.endDate, budgetAmount: budget.budgetAmount ?? 0, spentAmount: budget.spentAmount, carryoverAmount: budget.carryoverAmount, categories: budget.categories)
    }
    
    var body: some View {
        ZStack {
            tm.selectedTheme.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                picker(history: vm.selectedBudget < 0 ? budgetHistory : budget.history[vm.selectedBudget])
                
                progress(history: vm.selectedBudget < 0 ? budgetHistory : budget.history[vm.selectedBudget])
                
                ScrollView {
                    transactionListView
                }
                .padding(.top, 10)
            }
            .navigationTitle(budget.name)
            .navigationBarTitleDisplayMode(.inline)
            .modifier(CustomBackButtonModifier(dismiss: dismiss))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        vm.isBudgetSheetShown.toggle()
                    }, label: {
                        Image(systemName: "gear")
                            .foregroundColor(tm.selectedTheme.primaryColor)
                    })
                }
            }
            .sheet(isPresented: $vm.isBudgetSheetShown) {
                BudgetSheetView(budget: budget, parentVM: vm.parentVM, transactionService: TransactionService()) { budget in
                    Task {
                        vm.loading = true
                        
                        await vm.configureTransactions(transactions: transactionVM.getBudgetTransactions(budget: budget, history: budgetHistory))
                        
                        vm.loading = false
                    }
                }
            }
            .onChange(of: transactionVM.loading, perform: { loading in
                if !loading {
                    Task {
                        vm.loading = true
                        
                        await vm.configureTransactions(transactions: transactionVM.getBudgetTransactions(budget: budget, history: vm.selectedBudget < 0 ? budgetHistory : budget.history[vm.selectedBudget]))
                        
                        vm.loading = false
                    }
                }
            })
            .analyticsScreen(name: self.pageTitle, class: self.pageTitle)
        }
    }
}

struct BudgetDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let mockBudget = Budget(budgetAmount: 100000, spentAmount: 15000, carryover: true, carryoverAmount: 10000, history: [
            .init(startDate: Calendar.current.date(byAdding: .day, value: -7, to: Date())!, endDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, budgetAmount: 100, spentAmount: 10, carryoverAmount: 100, categories: [])
        ])
        
        BudgetDetailView(budget: mockBudget, parentVM: BudgetViewModel(budgetService: MockBudgetService()))
            .withPreviewEnvironmentObjects()
    }
}

extension BudgetDetailView {
    func picker(history: BudgetHistory) -> some View {
        HStack {
            if !budget.history.isEmpty && vm.selectedBudget < budget.history.count - 1 {
                Button {
                    if vm.selectedBudget < budget.history.count - 1 {
                        withAnimation {
                            vm.selectedBudget += 1
                        }
                    }
                } label: {
                    Image(systemName: "chevron.left")
                }
                .foregroundColor(tm.selectedTheme.primaryColor)
                .frame(width: 20)
            } else {
                Spacer()
                    .frame(width: 20)
            }
            
            Spacer()
            
            Text("\(history.startDate.addOneSecond.getDateAndMonthString) - \(history.endDate.getDateAndMonthString)")
                .font(.system(size: 16))
                .fontWeight(.medium)
                .foregroundColor(tm.selectedTheme.secondaryColor)
                .padding(.horizontal, 5)
            
            Spacer()
            
            if !budget.history.isEmpty && vm.selectedBudget != -1 {
                Button {
                    if vm.selectedBudget != -1 {
                        withAnimation {
                            vm.selectedBudget -= 1
                        }
                    }
                } label: {
                    Image(systemName: "chevron.right")
                }
                .foregroundColor(tm.selectedTheme.primaryColor)
                .frame(width: 20)
            } else {
                Spacer()
                    .frame(width: 20)
            }
        }
        .frame(height: 40)
        .padding(.horizontal)
        .onAppear {
            Task {
                vm.loading = true
                
                await vm.configureTransactions(transactions: transactionVM.getBudgetTransactions(budget: budget, history: budgetHistory))
                
                vm.loading = false
            }
        }
        .onChange(of: vm.selectedBudget) { index in
            Task {
                vm.loading = true
                
                await vm.configureTransactions(transactions: transactionVM.getBudgetTransactions(budget: budget, history: index < 0 ? budgetHistory : budget.history[index]))
                
                vm.loading = false
            }
        }
    }
    
    func progress(history: BudgetHistory) -> some View {
        GeometryReader { proxy in
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        AmountTextView("\(sm.currencySymbols ? currencyCode.currencySymbol : currencyCode) \(((history.budgetAmount + history.carryoverAmount) - history.spentAmount).toString)")
                            .font(.title.weight(.medium))
                        
                        VStack {
                            Spacer()
                            
                            Text(history.overbudget ? "over" : "left")
                                .fontWeight(.medium)
                                .font(.subheadline)
                                .foregroundColor(history.overbudget ? .red : tm.selectedTheme.secondaryLabel)
                        }
                        
                        Spacer()
                        
                        VStack {
                            Spacer()
                            
                            AmountTextView("\(((history.budgetAmount) + history.carryoverAmount).toString)")
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(tm.selectedTheme.secondaryLabel)
                        }
                    }
                    
                    ProgressView(value: history.budgetProgress)
                        .padding(.bottom, 10)
                        .tint(tm.selectedTheme.primaryColor)
                }
                
                Spacer()
            }
        }
        .frame(height: 40)
        .padding(.leading, 20)
        .padding(.trailing, 10)
    }
    
    var transactionListView: some View {
        TransactionListView(selectedTransaction: $vm.selectedTransaction, transactions: vm.transactions, onDelete: { transaction in
            Task {
                await transactionVM.deleteTransaction(transaction: transaction, walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM)
            }
        })
        .redacted(reason: transactionVM.loading || vm.loading ? .placeholder : [])
        .sheet(item: $vm.selectedTransaction) { transaction in
            TransactionSheetView(transactions: [transaction],
                                 isViewMode: true,
                                 isRecurringMode: false
            )
        }
    }
}
