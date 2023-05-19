//
//  MediumBudgetWidget.swift
//  WidgetsExtension
//
//  Created by Joses Solmaximo on 25/04/23.
//

import SwiftUI
import WidgetKit

struct MediumBudgetWidget: View {
    @AppStorage("currencyCode", store: .grouped) var currencyCode: String = ""
    
    @EnvironmentObject var tm: ThemeManager
    
    @ObservedObject var sm = SettingsManager.shared
    
    let entry: BudgetWidgetEntry
    
    var body: some View {
        ZStack {
            tm.selectedTheme.backgroundColor
                .ignoresSafeArea()
            
            GeometryReader { proxy in
                if let budget = entry.budgets.first(where: { $0.id.uuidString == entry.configuration.budget?.identifier }) ?? entry.budgets.first {
                    
                    HStack(spacing: 0) {
                        WidgetTransactionRow(transactions: entry.transactions.filter({
                            budget.categories.contains($0.category) &&
                            budget.range.contains($0.date) &&
                            $0.budgetRefs.contains(budget.id.uuidString)
                        }), categories: entry.categories, numberOfTransactions: 4)
                            .frame(width: proxy.size.width * 0.60 - 10)
                        
                        if entry.configuration.showsShortcuts == 1 {
                            ShortcutGrid(shortcuts: entry.shortcuts, columns: 2, slots: 4)
                                .frame(width: proxy.size.width * 0.40)
                                .padding(.leading, 2.5)
                        } else {
                            HStack(spacing: 0) {
                                budgetSection(budget: budget)
                            }
                            .frame(width: proxy.size.width * 0.40)
                            .padding(.leading, 5)
                        }
                    }
                } else {
                    VStack {
                        Spacer()
                        
                        HStack {
                            Spacer()
                            
                            Text("NO BUDGETS")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(tm.selectedTheme.secondaryLabel)
                            
                            Spacer()
                        }
                        
                        Spacer()
                    }
                }
            }
            
            if entry.configuration.showsAddButton != 0 && entry.configuration.showsShortcuts != 1 {
                AddButton()
            }
        }
    }
}

struct MediumBudgetWidget_Previews: PreviewProvider {
    static var previews: some View {
        let mockDatabase = MockDatabase()
        
        let transactions = Array(MockTransactionService(db: mockDatabase).transactions.prefix(10))
        
        let entry = BudgetWidgetEntry(date: Date(), configuration: .init(), budgets: defaultBudgets, transactions: transactions, categories: mockDatabase.categories)
        
        MediumBudgetWidget(entry: entry)
            .environmentObject(ThemeManager())
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

extension MediumBudgetWidget {
    func transactionRow(transaction: Transaction) -> some View {
        HStack(spacing: 0) {
            let category: Category? = entry.categories.first(where: { $0.id.uuidString == transaction.category })
            
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
    
    func budgetSection(budget: Budget) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading) {
                    Text(budget.name)
                        .lineLimit(1)
                        .font(.system(size: 17, weight: .medium))
                        .padding(.trailing, 25)
                    
                    HStack {
                        let startMonth = budget.startDate.addOneSecond.formatAs(.shortMonth)
                        let endMonth = budget.endDate.formatAs(.shortMonth)
                        
                        if startMonth == endMonth {
                            Text(budget.startDate.addOneSecond.formatAs(.date))
                            +
                            Text(" - ")
                            +
                            Text(budget.endDate.formatAs(.dayAndShortMonth).uppercased())
                        } else {
                            Text(budget.startDate.addOneSecond.formatAs(.dayAndShortMonth).uppercased())
                            +
                            Text(" - ")
                            +
                            Text(budget.endDate.formatAs(.dayAndShortMonth).uppercased())
                        }
                    }
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(tm.selectedTheme.secondaryLabel)
                }
                
                Spacer()
            }
            .padding(.top, 7)
            .padding(.bottom, 5)
            
            Spacer()
            
            HStack(alignment: .bottom) {
                HStack(spacing: 5) {
                    Text(sm.currencySymbols ? currencyCode.currencySymbol : currencyCode)
                        .foregroundColor(tm.selectedTheme.tertiaryLabel)
                    
                    AmountTextView((((budget.budgetAmount ?? 0) + budget.carryoverAmount) - budget.spentAmount).doubleValue.abbreviated)
                        .font(.system(size: 22, weight: .medium))
                        .lineLimit(1)
                        .layoutPriority(1)
                }
                .font(.system(size: 22))
                
                VStack {
                    Text(budget.overbudget ? "over" : "left")
                        .fontWeight(.medium)
                        .font(.subheadline)
                        .foregroundColor(budget.overbudget ? .red : tm.selectedTheme.secondaryColor)
                }
            }
            .padding(.trailing, -8)
            
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    let width = proxy.size.width
                    
                    RoundedRectangle(cornerRadius: 3)
                        .frame(width: width, height: 10)
                        .foregroundColor(tm.selectedTheme.primaryColor.opacity(0.1))
                    
                    RoundedRectangle(cornerRadius: 3)
                        .frame(width: width * CGFloat((budget.budgetProgress > 1 ? 1 : budget.budgetProgress)), height: 10)
                        .foregroundColor(tm.selectedTheme.primaryColor)
                }
            }
            .frame(height: 10)
            .padding(.vertical, 5)
            
            HStack {
                Text("0")
                
                Spacer()
                
                AmountTextView(((budget.budgetAmount ?? 0) + budget.carryoverAmount).doubleValue.abbreviated)
                    .lineLimit(1)
            }
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(tm.selectedTheme.secondaryColor)
            .padding(.bottom, 5)
        }
        .foregroundColor(tm.selectedTheme.primaryLabel)
        .padding([.vertical, .trailing], 8)
    }
}
