//
//  WalletDetail.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 14/10/22.
//

import SwiftUI
import FirebaseAnalyticsSwift
import Charts

struct WalletDetailView: View {
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("currencyCode", store: .grouped) var currencyCode: String = ""
    
    @EnvironmentObject var transactionVM: TransactionViewModel
    @EnvironmentObject var walletVM: WalletViewModel
    @EnvironmentObject var budgetVM: BudgetViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    @EnvironmentObject var categoryVM: CategoryViewModel
    @EnvironmentObject var tm: ThemeManager
    
    @StateObject var vm: WalletDetailViewModel
    
    @ObservedObject var sm = SettingsManager.shared
    
    let wallet: Wallet
    
    init(wallet: Wallet, parentVM: WalletViewModel) {
        self.wallet = wallet
        self._vm = StateObject(wrappedValue: WalletDetailViewModel(parentVM: parentVM))
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                tm.selectedTheme.backgroundColor
                    .ignoresSafeArea()
                
                VStack {
                    ScrollView(showsIndicators: false) {
                        chartHeader
                            .redacted(reason: vm.loading ? .placeholder : [])
                        
                        chart(proxy: proxy)
                        
                        transactionListView
                    }
                }
                
            }
            .navigationTitle(wallet.name)
            .navigationBarTitleDisplayMode(.inline)
            .modifier(CustomBackButtonModifier(dismiss: dismiss))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        vm.isWalletSheetShown.toggle()
                    }, label: {
                        Image(systemName: "gear")
                    })
                    .foregroundColor(tm.selectedTheme.primaryColor)
                }
            }
            .onChange(of: transactionVM.loading, perform: { loading in
                if !loading {
                    Task {
                        vm.loading = true
                        
                        await vm.configureTransactions(transactions: transactionVM.getWalletTransactions(startDate: Date().startOfMonth().removedTime, endDate: Date().endOfMonth().endOfDay), wallet: wallet)
                        
                        vm.loading = false
                    }
                }
            })
            .onAppear {
                Task {
                    vm.loading = true
                    
                    await vm.configureTransactions(transactions: transactionVM.getWalletTransactions(startDate: Date().startOfMonth().removedTime, endDate: Date().endOfMonth().endOfDay), wallet: wallet)
                    
                    vm.loading = false
                }
            }
            .sheet(isPresented: $vm.isWalletSheetShown) {
                WalletSheetView(wallet: wallet, parentVM: vm.parentVM)
            }
        }
        .analyticsScreen(name: self.pageTitle, class: self.pageTitle)
    }
}

struct WalletDetail_Previews: PreviewProvider {
    static var previews: some View {
        let parentVM = WalletViewModel(walletService: MockWalletService())
        
        WalletDetailView(wallet: defaultWallets[0], parentVM: parentVM)
            .withPreviewEnvironmentObjects()
    }
}

extension WalletDetailView {
    var chartHeader: some View {
        VStack {
            let amounts = vm.chartTab == .income ? vm.incomeAmounts : vm.chartTab == .expense ? vm.expenseAmounts : vm.totalAmounts
            
            Picker("", selection: $vm.chartTab) {
                ForEach(ChartTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue)
                        .tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 10)
            .unredacted()
            
            HStack {
                Text("\(vm.showPlot ? vm.validSections.reversed()[vm.currentDate].formattedWithoutYear : Date().getMonthString)")
                    .foregroundColor(tm.selectedTheme.primaryLabel)
                    .fontWeight(.medium)
                
                Spacer()
            }
            .padding(.horizontal)
            
            HStack(spacing: 5) {
                Text(sm.currencySymbols ? currencyCode.currencySymbol : currencyCode)
                    .font(.system(size: 26, weight: .medium))
                    .foregroundColor(tm.selectedTheme.tertiaryLabel)
                
                let shownAmount = vm.chartTab == .total && !vm.showPlot ? wallet.amount.doubleValue.toString : vm.showPlot ? vm.currentPlot : vm.validSections.map { return abs(amounts[$0]!) }.reduce(0, +).toString
                
                AmountTextView(shownAmount)
                    .foregroundColor(tm.selectedTheme.primaryLabel)
                    .font(.system(size: 26).weight(.medium))
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    func chart(proxy: GeometryProxy) -> some View {
        if vm.validSections.count > 1 &&
            (
                vm.chartTab == .total ? vm.totalAmounts.values.contains(where: {$0 != 0})
                : vm.chartTab == .expense ? vm.expenseAmounts.values.contains(where: {$0 != 0})
                : vm.incomeAmounts.values.contains(where: {$0 != 0})
            )
        {
            ZStack {
                let amounts = vm.chartTab == .income ? vm.incomeAmounts : vm.chartTab == .expense ? vm.expenseAmounts : vm.totalAmounts
                
                Chart(data: vm.validSections.map { section in
                    return CGFloat(abs(amounts[section] ?? 0))/(vm.validSections.map { section in
                        return CGFloat(abs(amounts[section] ?? 0))
                    }.max() ?? 1)
                }.reversed())
                .chartStyle(
                    AreaChartStyle(sm.lineGraphStyle == .straight ? .line : .quadCurve, fill:
                                    LinearGradient(gradient: .init(colors: [Color.blue.opacity(0.2), Color.blue.opacity(0.01)]), startPoint: .top, endPoint: .bottom)
                                  )
                )
                .frame(height: 100)
                
                Chart(data: vm.validSections.map { section in
                    return CGFloat(abs(amounts[section] ?? 0))/(vm.validSections.map { section in
                        return CGFloat(abs(amounts[section] ?? 0))
                    }.max() ?? 1)
                }.reversed())
                .chartStyle(
                    LineChartStyle(sm.lineGraphStyle == .straight ? .line : .quadCurve, lineColor: .blue, lineWidth: 2)
                )
                .frame(height: 100)
                
                if vm.showPlot {
                    Circle()
                        .fill(tm.selectedTheme.tintColor)
                        .frame(width: 15, height: 15)
                        .overlay(
                            Circle()
                                .fill(tm.selectedTheme.backgroundColor)
                                .frame(width: 7.5, height: 7.5)
                        )
                        .offset(x: vm.offsetX, y: vm.offsetY)
                }
            }
            .gesture(DragGesture().onChanged({ value in
                let amounts = vm.chartTab == .income ? vm.incomeAmounts : vm.chartTab == .expense ? vm.expenseAmounts : vm.totalAmounts
                
                vm.showPlot = true
                
                let data = Array(vm.validSections.map { section in
                    return CGFloat(abs(amounts[section] ?? 0))/(vm.validSections.map { section in
                        return CGFloat(abs(amounts[section] ?? 0))
                    }.max() ?? 1)
                }.reversed())
                
                let section = proxy.size.width / CGFloat(data.count - 1)
                let sectionBreakpoints = data.enumerated().map { (index, data) in
                    return CGFloat(index) * section
                }
                
                if let closest = sectionBreakpoints.nearest(to: value.location.x) {
                    vm.offsetX = CGFloat(closest.element) - proxy.size.width/2
                    vm.offsetY = -CGFloat(data[closest.offset] * 100) + 50
                    
                    vm.currentPlot = "\(abs(amounts[vm.validSections.reversed()[closest.offset]] ?? 0).toString)"
                    vm.currentDate = closest.offset
                }
            })
                .onEnded({ value in
                    vm.showPlot = false
                }))
        } else {
            ZStack {
                Chart(data: [0.5, 0.5])
                    .chartStyle(
                        AreaChartStyle(sm.lineGraphStyle == .straight ? .line : .quadCurve, fill:
                                        LinearGradient(gradient: .init(colors: [Color.blue.opacity(0.2), Color.blue.opacity(0.01)]), startPoint: .top, endPoint: .bottom)
                                      )
                    )
                    .frame(height: 100)
                
                Chart(data: [0.5, 0.5])
                    .chartStyle(
                        LineChartStyle(sm.lineGraphStyle == .straight ? .line : .quadCurve, lineColor: .blue, lineWidth: 2)
                    )
                    .frame(height: 100)
            }
        }
    }
    
    var transactionListView: some View {
        TransactionListView(
            selectedTransaction: $vm.selectedTransaction,
            transactions: vm.chartTab == .total ? vm.transactions
            : vm.chartTab == .expense ? vm.expenseTransactions
            : vm.incomeTransactions,
            onDelete: { transaction in
                Task {
                    await transactionVM.deleteTransaction(transaction: transaction, walletVM: walletVM, budgetVM: budgetVM, categoryVM: categoryVM)
                }
            })
        .redacted(reason: transactionVM.loading ? .placeholder : [])
        .sheet(item: $vm.selectedTransaction) { transaction in
            TransactionSheetView(transactions: [transaction],
                                 isViewMode: true,
                                 isRecurringMode: false
            )
        }
    }
}

