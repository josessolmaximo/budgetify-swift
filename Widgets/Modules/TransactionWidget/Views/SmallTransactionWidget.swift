//
//  SmallTransactionWidget.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 19/04/23.
//

import SwiftUI
import WidgetKit

struct SmallTransactionWidget: View {
    @AppStorage("currencyCode", store: .grouped) var currencyCode: String = ""
    
    @EnvironmentObject var tm: ThemeManager
    
    @ObservedObject var sm = SettingsManager.shared
    
    let entry: TransactionWidgetEntry
    
    var body: some View {
        ZStack {
            tm.selectedTheme.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                let isLoading = entry.categories.isEmpty
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(entry.configuration.period.toString.uppercased())
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(tm.selectedTheme.secondaryColor)
                        
                        HStack(spacing: 3) {
                            Text(sm.currencySymbols ? currencyCode.currencySymbol : currencyCode)
                                .foregroundColor(tm.selectedTheme.tertiaryLabel)
                            
                            AmountTextView(entry.transactions.filter({ $0.type != .transfer }).reduce(0, { result, transaction in
                                transaction.type == .expense ? result - (transaction.amount ?? 0) : result + (transaction.amount ?? 0)
                            }).doubleValue.abbreviated)
                            .redacted(reason: isLoading ? .placeholder: [])
                        }
                        .font(.system(size: 17, weight: .medium))
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.top, 12)
                .padding(.bottom, 8)
                
                VStack(spacing: 5) {
                    if entry.transactions.isEmpty {
                        Spacer()
                    }
                    
                    ForEach(Array(entry.transactions.prefix(3))) { transaction in
                        HStack(spacing: 0) {
                            let category: Category? = entry.categories.first(where: { $0.id.uuidString == transaction.category })
                            
                            Rectangle()
                                .frame(width: 3, height: 27.5)
                                .foregroundColor(transaction.type == .transfer ? tm.selectedTheme.secondaryLabel : category?.color.stringToColor() ?? tm.selectedTheme.secondaryLabel)
                            
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
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(category?.type == .expense ? tm.selectedTheme.primaryColor : category?.type == .income ? .green : tm.selectedTheme.secondaryColor)
                            .layoutPriority(1)
                        }
                        .padding(.horizontal, 8)
                        .frame(height: 27.5)
                    }
                    
                    if entry.transactions.isEmpty {
                        Text("NO TRANSACTIONS")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(tm.selectedTheme.secondaryLabel)
                        
                        Spacer()
                        
                        Spacer()
                    }
                }
                
                Spacer()
            }
            
            if entry.configuration.showsAddButton != 0 {
                AddButton()
            }
        }
        .widgetURL(URL(string: "budgetify://transaction")!)
    }
}

struct SmallTransactionWidget_Previews: PreviewProvider {
    static var previews: some View {
        let mockDatabase = MockDatabase()
        
        let transactions = Array(MockTransactionService(db: mockDatabase).transactions.prefix(10))
        
        let placeholder = TransactionWidgetEntry(date: Date(), configuration: ConfigurationIntent(), transactions: transactions, categories: mockDatabase.categories)
        
        SmallTransactionWidget(entry: placeholder)
            .environmentObject(ThemeManager())
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
