//
//  TransactionListView.swift
//  ExpenseTracker
//
//  Created by Joses Solmaximo on 19/12/22.
//

import SwiftUI
import OrderedCollections

struct TransactionListView: View {
    @AppStorage("currencyCode", store: .grouped) var currencyCode: String = ""
    
    @EnvironmentObject var categoryVM: CategoryViewModel
    @EnvironmentObject var walletVM: WalletViewModel
    @EnvironmentObject var tm: ThemeManager
    
    @Binding var selectedTransaction: Transaction?
    
    let transactions: OrderedDictionary<Date, [Transaction]>
    
    let onDelete: ((_ transaction: Transaction) -> ())?
    
    var body: some View {
        LazyVStack {
            ForEach(Array(transactions.keys), id: \.self) { section in
                HStack {
                    Text(section.formattedWithoutYear.uppercased())
                        .font(.system(size: 13))
                        .fontWeight(.semibold)
                        .foregroundColor(tm.selectedTheme.primaryLabel)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 5)
                
                ForEach(transactions[section] ?? []){ transaction in
                    SwipeItem(content: {
                        TransactionRow(selectedTransaction: $selectedTransaction, transaction: transaction, mode: .normal)
                    }, left: {
                        Color.clear
                    }, right: {
                        Button(action: {
                            onDelete?(transaction)
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
        }
    }
}

struct TransactionListView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionListView(selectedTransaction: .constant(nil), transactions: [Date(): MockTransactionService().transactions], onDelete: nil)
            .environmentObject(ThemeManager())
            .environmentObject(CategoryViewModel(categoryService: MockCategoryService()))
            .environmentObject(WalletViewModel(walletService: MockWalletService()))
    }
}
