//
//  MediumTransactionWidget.swift
//  WidgetsExtension
//
//  Created by Joses Solmaximo on 20/04/23.
//

import SwiftUI
import WidgetKit

struct MediumTransactionWidget: View {
    @AppStorage("currencyCode", store: .grouped) var currencyCode: String = ""
    
    @EnvironmentObject var tm: ThemeManager
    
    @ObservedObject var sm = SettingsManager.shared
    
    let entry: TransactionWidgetEntry
    
    let columns = [
        GridItem(.fixed(60), spacing: 15),
        GridItem(.fixed(60), spacing: 15),
    ]
    
    let slots = (1...4)
    
    var body: some View {
        ZStack {
            tm.selectedTheme.backgroundColor
                .ignoresSafeArea()
            
            GeometryReader { proxy in
                let isLoading = entry.categories.isEmpty
                
                HStack(spacing: 0) {
                    WidgetTransactionRow(transactions: entry.transactions, categories: entry.categories, numberOfTransactions: 4)
                        .frame(width: proxy.size.width * 0.60 - 10)
                    
                    if entry.configuration.showsShortcuts != 0 {
                        ShortcutGrid(shortcuts: entry.shortcuts, columns: 2, slots: 4)
                        .frame(width: proxy.size.width * 0.40)
                        .padding(.leading, 2.5)
                    } else {
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                VStack(alignment: .leading) {
                                    Text(entry.configuration.period.toString.uppercased())
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(tm.selectedTheme.secondaryColor)
                                    
                                    HStack(spacing: 3) {
                                        Text(sm.currencySymbols ? currencyCode.currencySymbol : currencyCode)
                                            .foregroundColor(tm.selectedTheme.tertiaryLabel)
                                        
                                        AmountTextView(entry.transactions.reduce(0, { result, transaction in
                                            transaction.type == .expense ? result - (transaction.amount ?? 0) : result + (transaction.amount ?? 0)
                                        }).toString)
                                            .lineLimit(1)
                                            .redacted(reason: isLoading ? .placeholder: [])
                                    }
                                    .font(.system(size: 17, weight: .medium))
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("EXPENSES")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(tm.selectedTheme.secondaryColor)
                                    
                                    HStack(spacing: 3) {
                                        Text(sm.currencySymbols ? currencyCode.currencySymbol : currencyCode)
                                            .foregroundColor(tm.selectedTheme.tertiaryLabel)
                                        
                                        AmountTextView(entry.transactions.reduce(0, { result, transaction in
                                            transaction.type == .expense ? result + (transaction.amount ?? 0) : result + 0
                                        }).toString)
                                            .lineLimit(1)
                                            .foregroundColor(.red)
                                            .redacted(reason: isLoading ? .placeholder: [])
                                    }
                                    .font(.system(size: 17, weight: .medium))
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("INCOME")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(tm.selectedTheme.secondaryColor)
                                    
                                    HStack(spacing: 3) {
                                        Text(sm.currencySymbols ? currencyCode.currencySymbol : currencyCode)
                                            .foregroundColor(tm.selectedTheme.tertiaryLabel)
                                        
                                        AmountTextView(entry.transactions.reduce(0, { result, transaction in
                                            transaction.type == .expense ? result + 0 : result + (transaction.amount ?? 0)
                                        }).toString)
                                            .lineLimit(1)
                                            .foregroundColor(.green)
                                            .redacted(reason: isLoading ? .placeholder: [])
                                    }
                                    .font(.system(size: 17, weight: .medium))
                                }
                            }
                            
                            Spacer()
                        }
                        .frame(width: proxy.size.width * 0.40)
                        .padding(.leading, 5)
                    }
                }
            }
            
            if entry.configuration.showsAddButton != 0 && entry.configuration.showsShortcuts != 1 {
                AddButton()
            }
        }
    }
}

struct MediumTransactionWidget_Previews: PreviewProvider {
    static var previews: some View {
        let mockDatabase = MockDatabase()
        
        let transactions = Array(MockTransactionService(db: mockDatabase).transactions.prefix(10))
        
        let placeholder = TransactionWidgetEntry(date: Date(), configuration: ConfigurationIntent(), transactions: transactions, categories: mockDatabase.categories)
        
        MediumTransactionWidget(entry: placeholder)
            .environmentObject(ThemeManager())
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
