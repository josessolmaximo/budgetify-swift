//
//  RecurringView.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 16/11/22.
//

import SwiftUI
import FirebaseAnalyticsSwift

struct RecurringView: View {
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("currencyCode", store: .grouped) var currencyCode: String = ""
    
    @EnvironmentObject var vm: RecurringViewModel
    @EnvironmentObject var transactionVM: TransactionViewModel
    @EnvironmentObject var categoryVM: CategoryViewModel
    @EnvironmentObject var walletVM: WalletViewModel
    
    @EnvironmentObject var tm: ThemeManager
    
    @ObservedObject var sm = SettingsManager.shared
    
    var body: some View {
        ZStack {
            tm.selectedTheme.backgroundColor
                .ignoresSafeArea()
            
            ScrollView {
                VStack {
                    ForEach(vm.organizedTransactions.keys, id: \.self) { section in
                        recurringSection(header: section)
                            .redacted(reason: vm.loading ? .placeholder : [])
                    }
                }
            }
            .navigationTitle("Recurring Transactions")
            .navigationBarTitleDisplayMode(.inline)
            .modifier(CustomBackButtonModifier(dismiss: dismiss))
            .onChange(of: vm.allTransactions) { _ in
                vm.organizeRecurringTransactions()
            }
            .sheet(item: $vm.selectedTransaction) { transaction in
                TransactionSheetView(transactions: [transaction], isViewMode: true, isRecurringMode: true)
            }
        }
        .analyticsScreen(name: self.pageTitle, class: self.pageTitle)
    }
}

extension RecurringView {
    func recurringSection(header: String) -> some View {
        VStack {
            HStack {
                Text(header.uppercased())
                    .font(.system(size: 13))
                    .fontWeight(.semibold)

                Spacer()
            }
            .padding(.horizontal)

            ForEach(vm.organizedTransactions[header] ?? []) { transaction in
                SwipeItem(content: {
                    TransactionRow(selectedTransaction: $vm.selectedTransaction, transaction: transaction, mode: .normal)
                }, left: {
                    Color.clear
                }, right: {
                    Button(action: {
                        Task {
                            await vm.deleteTransaction(transaction: transaction)
                        }
                    }, label: {
                        ZStack {
                            Color.red
                            Image(systemName: "trash")
                                .foregroundColor(.white)
                        }
                    })
                }, itemHeight: 40)
                .frame(height: 40)
            }
        }
        .padding(.bottom, 5)
    }
}

struct RecurringView_Previews: PreviewProvider {
    static var previews: some View {
        RecurringView()
    }
}
