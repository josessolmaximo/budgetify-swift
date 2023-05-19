//
//  SmallBudgetWidget.swift
//  WidgetsExtension
//
//  Created by Joses Solmaximo on 22/04/23.
//

import SwiftUI
import WidgetKit

struct SmallBudgetWidget: View {
    @AppStorage("currencyCode", store: .grouped) var currencyCode: String = ""
    
    @EnvironmentObject var tm: ThemeManager
    
    @ObservedObject var sm = SettingsManager.shared
    
    let entry: BudgetWidgetEntry
    
    var body: some View {
        if let budget = entry.budgets.first(where: { $0.id.uuidString == entry.configuration.budget?.identifier }) ?? entry.budgets.first {
            ZStack {
                tm.selectedTheme.backgroundColor
                    .ignoresSafeArea()

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
                    .padding(.top, 2.5)
                    .padding(.bottom, 5)

                    Spacer()

                    HStack(alignment: .bottom) {
                        HStack(spacing: 5) {
                            Text(sm.currencySymbols ? currencyCode.currencySymbol : currencyCode)
                                .foregroundColor(tm.selectedTheme.tertiaryLabel)

                            AmountTextView((((budget.budgetAmount ?? 0) + budget.carryoverAmount) - budget.spentAmount).doubleValue.abbreviated)
                                .font(.system(size: 22, weight: .medium))
                                .lineLimit(1)
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
                .padding(8)

                if entry.configuration.showsAddButton != 0 {
                    AddButton()
                }
            }
            .widgetURL(URL(string: "budgetify://transaction")!)
        } else {
            Text("NO BUDGETS")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(tm.selectedTheme.secondaryLabel)
        }
    }
}

struct SmallBudgetWidget_Previews: PreviewProvider {
    static var previews: some View {
        let entry = BudgetWidgetEntry(date: Date(), configuration: .init(), budgets: defaultBudgets)
        
        SmallBudgetWidget(entry: entry)
            .environmentObject(ThemeManager())
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
