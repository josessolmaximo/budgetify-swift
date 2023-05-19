//
//  MediumReportWidget.swift
//  WidgetsExtension
//
//  Created by Joses Solmaximo on 26/04/23.
//

import SwiftUI
import Charts
import OrderedCollections
import WidgetKit

struct MediumReportWidget: View {
    @AppStorage("currencyCode", store: .grouped) var currencyCode: String = ""
    
    @EnvironmentObject var tm: ThemeManager
    
    @ObservedObject var sm = SettingsManager.shared
    
    let entry: ReportWidgetEntry
    
    var body: some View {
        ZStack {
            tm.selectedTheme.backgroundColor
                .ignoresSafeArea()
            
            GeometryReader { proxy in
                HStack(spacing: 0) {
                    VStack(spacing: 5) {
                        HStack {
                            VStack(alignment: .leading) {
                                HStack(spacing: 5) {
                                    Text(entry.configuration.period.toString.uppercased())
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(tm.selectedTheme.secondaryColor)
                                    
                                    let isExpense = entry.configuration.transactionType == .expense
                                    
                                    Image(systemName: isExpense ? "arrow.up.circle" : "arrow.down.circle")
                                        .font(.system(size: 12))
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(.black, isExpense ? .red :  .green)
                                }
                                
                                HStack(spacing: 3) {
                                    Text(sm.currencySymbols ? currencyCode.currencySymbol : currencyCode)
                                        .foregroundColor(tm.selectedTheme.tertiaryLabel)
                                    
                                    AmountTextView(entry.totalAmount.toString)
                                }
                                .font(.system(size: 17, weight: .medium))
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("AVG / DAY")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(tm.selectedTheme.secondaryColor)
                                
                                HStack(spacing: 3) {
                                    Text(sm.currencySymbols ? currencyCode.currencySymbol : currencyCode)
                                        .foregroundColor(tm.selectedTheme.tertiaryLabel)
                                    
                                    AmountTextView((entry.totalAmount.doubleValue/Double(entry.dates.count)).abbreviated)
                                }
                                .font(.system(size: 17, weight: .medium))
                            }
                        }
                        
                        HStack {
                            ZStack {
                                HStack {
                                    Chart(data: entry.chartData)
                                        .chartStyle(
                                            ColumnChartStyle(column: RoundedRectangle(cornerRadius: entry.chartData.count > 7 ? 2 : 5).foregroundColor(tm.selectedTheme.primaryColor), spacing: entry.chartData.count > 7 ? 1.5 : 3)
                                        )
                                }
                                
                                HStack {
                                    Chart(data: entry.chartData.map({ _ in return 1.0 }))
                                        .chartStyle(
                                            ColumnChartStyle(column: RoundedRectangle(cornerRadius: entry.chartData.count > 7 ? 2 : 5).foregroundColor(tm.selectedTheme.primaryColor).opacity(0.1), spacing: entry.chartData.count > 7 ? 1.5 : 3)
                                        )
                                }
                            }
                            
                        }
                        
                        Spacer()
                            .frame(maxHeight: 5)
                    }
                    .frame(width: proxy.size.width * 0.6 - 20)
                    .padding(.trailing, 10)
                    
                    
                    if entry.configuration.showsShortcuts == 1 {
                        ShortcutGrid(shortcuts: entry.shortcuts, columns: 2, slots: 4)
                            .frame(width: proxy.size.width * 0.4)
                            .offset(x: -5, y: -7.5)
                    } else {
                        VStack(spacing: 0) {
                            Spacer()
                                .frame(minHeight: 15)
                                .frame(maxHeight: 20)
                            
                            HStack(alignment: .bottom) {
                                if !entry.categoryData.keys.isEmpty {
                                    VStack(alignment: .leading) {
                                        Text("CATEGORIES")
                                            .font(.system(size: 10, weight: .medium))
                                            .foregroundColor(tm.selectedTheme.secondaryColor)
                                    }
                                    
                                    Spacer()
                                }
                            }
                            .padding(.bottom, 5)
                            
                            VStack(spacing: 5) {
                                ForEach(Array(entry.categoryData.keys.prefix(4))) { key in
                                    let category = entry.categories.first(where: { $0.id.uuidString == key })
                                    
                                    HStack(spacing: 20/3) {
                                        Rectangle()
                                            .frame(width: 3, height: 20)
                                            .foregroundColor(category?.color.stringToColor() ?? tm.selectedTheme.secondaryLabel)
                                        
                                        Text(category?.name ?? "Unknown")
                                            .fontWeight(.medium)
                                            .lineLimit(1)
                                            .redacted(reason: category == nil ? .placeholder : [])
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        HStack(spacing: 2.5){
                                            Text(sm.currencySymbols ? currencyCode.currencySymbol : currencyCode)
                                                .foregroundColor(tm.selectedTheme.tertiaryLabel)
                                            
                                            AmountTextView(entry.categoryData[key]?.doubleValue.abbreviated ?? "")
                                                .lineLimit(1)
                                        }
                                        .layoutPriority(1)
                                    }
                                    .font(.system(size: 13))
                                    .padding(.trailing, 5)
                                }
                            }
                            
                            if entry.categoryData.keys.isEmpty {
                                Spacer()
                                
                                VStack {
                                    Text("NO TRANSACTIONS")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(tm.selectedTheme.secondaryLabel)
                                        .padding(.trailing, 5)
                                }
                            }
                            
                            Spacer()
                                .background(.red)
                        }
                        .frame(width: proxy.size.width * 0.4)
                        .padding(.trailing, 10)
                    }
                }
                .padding(8)
            }
            
            if entry.configuration.showsAddButton != 0 && entry.configuration.showsShortcuts != 1 {
                AddButton()
            }
        }
    }
}

struct MediumReportWidget_Previews: PreviewProvider {
    static var previews: some View {
        let mockDatabase = MockDatabase()
        
        let transactions = Array(MockTransactionService(db: mockDatabase).transactions)
        
        let placeholder = ReportWidgetEntry(date: Date(), configuration: ReportConfigurationIntent(), transactions: transactions, categories: mockDatabase.categories)
        
        MediumReportWidget(entry: placeholder)
            .environmentObject(ThemeManager())
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
