//
//  SmallReportWidget.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 25/04/23.
//

import SwiftUI
import WidgetKit
import Charts
import OrderedCollections

struct SmallReportWidget: View {
    @AppStorage("currencyCode", store: .grouped) var currencyCode: String = ""
    
    @EnvironmentObject var tm: ThemeManager
    
    @ObservedObject var sm = SettingsManager.shared
    
    let entry: LimitedReportWidgetEntry
    
    var body: some View {
        ZStack {
            tm.selectedTheme.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 5) {
                HStack {
                    VStack(alignment: .leading) {
                        HStack(spacing: 5) {
                            Text("THIS WEEK")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(tm.selectedTheme.secondaryColor)
                            
                            let isExpense = entry.configuration.transactionType == .expense
                            
                            Image(systemName: isExpense ? "arrow.up.circle" : "arrow.down.circle")
                                .font(.system(size: 12))
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(tm.selectedTheme.primaryColor, isExpense ? .red :  .green)
                        }
                        .padding(.top, 5)
                        
                        HStack(spacing: 3) {
                            Text(sm.currencySymbols ? currencyCode.currencySymbol : currencyCode)
                                .foregroundColor(tm.selectedTheme.tertiaryLabel)
                            
                            AmountTextView(entry.totalAmount.doubleValue.abbreviated)
                        }
                        .font(.system(size: 17, weight: .medium))
                    }
                    
                    Spacer()
                }
//                .padding(.bottom, 5)
                
                ZStack {
                    let chartHeight: CGFloat = 80
                    
                    HStack {
                        Chart(data: entry.chartData)
                            .chartStyle(
                                ColumnChartStyle(column: RoundedRectangle(cornerRadius: entry.chartData.count > 7 ? 2 : 5).foregroundColor(tm.selectedTheme.primaryColor), spacing: 5)
                            )
                            .frame(height: chartHeight)
                    }
                    
                    HStack {
                        Chart(data: entry.chartData.map({ _ in return 1.0 }))
                            .chartStyle(
                                ColumnChartStyle(column: RoundedRectangle(cornerRadius: entry.chartData.count > 7 ? 2 : 5).foregroundColor(tm.selectedTheme.primaryColor).opacity(0.1), spacing: 5)
                            )
                            .frame(height: chartHeight)
                        
                    }
                }
                
                HStack {
                    ForEach(entry.dates, id: \.self) { day in
                        Text(day.formatAs(.day).prefix(1))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(day == Date().startOfDay ? tm.selectedTheme.tintColor : tm.selectedTheme.secondaryLabel)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 2.5)
            }
            .padding(8)
            
            if entry.configuration.showsAddButton != 0 {
                AddButton()
            }
        }
        .widgetURL(URL(string: "budgetify://transaction")!)
    }
}

struct SmallReportWidget_Previews: PreviewProvider {
    static var previews: some View {
        let mockDatabase = MockDatabase()
        
        let transactions = Array(MockTransactionService(db: mockDatabase).transactions)
        
        let placeholder = LimitedReportWidgetEntry(date: Date(), configuration: LimitedReportConfigurationIntent(), transactions: transactions, categories: mockDatabase.categories)
        
        SmallReportWidget(entry: placeholder)
            .environmentObject(ThemeManager())
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
