//
//  WidgetTransactionRow.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 29/04/23.
//

import SwiftUI

struct WidgetTransactionRow: View {
    @AppStorage("currencyCode", store: .grouped) var currencyCode: String = ""
    
    @EnvironmentObject var tm: ThemeManager
    
    @ObservedObject var sm = SettingsManager.shared
    
    let transactions: [Transaction]
    let categories: [Category]
    
    let numberOfTransactions: Int
    
    var body: some View {
        VStack(spacing: 5) {
            if transactions.isEmpty {
                Spacer()
            } else {
                Spacer()
                    .frame(maxHeight: 12.5)
            }
            
            ForEach(Array(transactions.prefix(numberOfTransactions))) { transaction in
                HStack(spacing: 0) {
                    let category: Category? = categories.first(where: { $0.id.uuidString == transaction.category })
                    
                    Rectangle()
                        .frame(width: 3, height: 27.5)
                        .foregroundColor(transaction.type == .transfer ? tm.selectedTheme.secondaryLabel : category?.color.stringToColor() ?? tm.selectedTheme.secondaryLabel)
                    
                    ZStack {
                        if transaction.type == .transfer {
                            CustomIconView(imageName: "arrow.left.arrow.right", dimensions: 17.5)
                                .foregroundColor(tm.selectedTheme.secondaryLabel)
                                .padding(.leading, 5)
                        } else {
                            CustomIconView(imageName: category?.image ?? "tray", dimensions: 17.5)
                                .redacted(reason: category == nil && transaction.type != .transfer ? .placeholder : [])
                                .foregroundColor(category?.color.stringToColor() ?? tm.selectedTheme.secondaryLabel)
                                .padding(.leading, 5)
                        }
                    }
                    .padding(.leading, 5)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            if transaction.type == .transfer {
                                Text("Transfer")
                                    .foregroundColor(tm.selectedTheme.primaryLabel)
                            } else {
                                Text(category?.name ?? "Unknown")
                                    .lineLimit(1)
                                    .redacted(reason: category == nil && transaction.type != .transfer ? .placeholder : [])
                                    .foregroundColor(tm.selectedTheme.primaryLabel)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .font(.system(size: 13, weight: .semibold))
                        
                        Text(transaction.date.formatted(date: .omitted, time: .shortened))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(tm.selectedTheme.secondaryColor)
                            .redacted(reason: category == nil && transaction.type != .transfer ? .placeholder : [])
                    }
                    .padding(.leading, 8)
                    .padding(.trailing, -5)
                    
                    Spacer()
                    
                    HStack(spacing: 3) {
                        Text(sm.currencySymbols ? currencyCode.currencySymbol : currencyCode)
                            .foregroundColor(tm.selectedTheme.tertiaryLabel)
                        
                        AmountTextView(transaction.amount?.doubleValue.abbreviated ?? "")
                            .redacted(reason: category == nil && transaction.type != .transfer ? .placeholder: [])
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(category?.type == .expense ? tm.selectedTheme.primaryColor : category?.type == .income ? .green : tm.selectedTheme.secondaryColor)
                    .layoutPriority(1)
                }
                .padding(.horizontal, 8)
                .frame(height: 27.5)
            }
            
            if transactions.isEmpty {
                Text("NO TRANSACTIONS")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(tm.selectedTheme.secondaryLabel)
            }
            
            Spacer()
        }
    }
}

struct WidgetTransactionRow_Previews: PreviewProvider {
    static var previews: some View {
        WidgetTransactionRow(transactions: [], categories: [], numberOfTransactions: 4)
    }
}
