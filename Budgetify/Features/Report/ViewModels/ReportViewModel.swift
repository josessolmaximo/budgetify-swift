//
//  InsightViewModel.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 28/11/22.
//

import Foundation
import OrderedCollections
import SwiftUI

@MainActor
class ReportViewModel: ObservableObject {
    @Published var period: InsightPeriod = .monthly
    
    @Published var chartData: [Double] = []
    @Published var transactionData: [Double] = []
    @Published var categoryData: OrderedDictionary<String, Double> = [:]
    @Published var timeData: OrderedDictionary<Date, Double> = [:]
    @Published var locationData: OrderedDictionary<String, Double> = [:]
    
    @Published var labels: [String] = []
    @Published var selectedLabel: String?
    @Published var selectedIndex: Int = 0
    @Published var labelOffset: CGFloat = 0
    @Published var labelWidth: CGFloat = 0
    
    @Published var seeAllCategories = false
    @Published var seeAllTime = false
    
    @Published var isSearchSheetShown = false
    
    public var prevIncomeSelected: Bool = false
    public var prevExpenseSelected: Bool = false
    public var prevTransferSelected: Bool = false
    
    func configureChart(transactionVM: TransactionViewModel, categories: [Category]){
        selectedLabel = nil
        
        var monthlyData: [Double] = []
        var categoryData: OrderedDictionary<String, Double> = [:]
        
        var timeArray = [Double](repeating: 0.0, count: 24)
        var timeData: OrderedDictionary<Date, Double> = [:]
        
        var startDate = transactionVM.startDate
        var dates: [Date] = []
        
        let selectedTypes = transactionVM.query.transactionType.filter({$0.value}).map({$0.key})
        
        switch transactionVM.filterType {
        case .daily:
            monthlyData = [Double](repeating: 0.0, count: 24)
            
            while startDate < transactionVM.endDate {
                dates.append(startDate)
                startDate = Calendar.current.date(byAdding: .hour, value: 1, to: startDate)!
            }
            
            for transaction in transactionVM.filteredTransactions {
                let calendarDate = Calendar.current.dateComponents([.hour], from: transaction.date)
                
                if selectedTypes.contains(transaction.type) {
                    monthlyData[calendarDate.hour!] += transaction.amount?.doubleValue ?? 0
                    categoryData[transaction.category, default: 0] += transaction.amount?.doubleValue ?? 0
                    timeArray[calendarDate.hour!] += transaction.amount?.doubleValue ?? 0
                }
            }
            
            labels = dates.map({ $0.toHourAndMinute })
        case .weekly:
            monthlyData = [Double](repeating: 0.0, count: 7)
            
            while startDate < transactionVM.endDate {
                dates.append(startDate)
                startDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
            }
            
            for transaction in transactionVM.filteredTransactions {
                let calendarDate = Calendar.current.dateComponents([.weekday, .hour], from: transaction.date)
                
                if selectedTypes.contains(transaction.type) {
                    monthlyData[calendarDate.weekday! - 1] += transaction.amount?.doubleValue ?? 0
                    categoryData[transaction.category, default: 0] += transaction.amount?.doubleValue ?? 0
                    timeArray[calendarDate.hour!] += transaction.amount?.doubleValue ?? 0
                }
            }
    
            labels = dates.map({ $0.toString })
        case .monthly:
            let range = Calendar.current.range(of: .day, in: .month, for: startDate)!
            monthlyData = [Double](repeating: 0.0, count: range.count)
            
            while startDate < transactionVM.endDate {
                dates.append(startDate)
                startDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
            }
            
            for transaction in transactionVM.filteredTransactions {
                let calendarDate = Calendar.current.dateComponents([.hour, .day], from: transaction.date)
                if selectedTypes.contains(transaction.type) {
                    monthlyData[calendarDate.day! - 1] += transaction.amount?.doubleValue ?? 0
                    categoryData[transaction.category, default: 0] += transaction.amount?.doubleValue ?? 0
                    timeArray[calendarDate.hour!] += transaction.amount?.doubleValue ?? 0
                }
            }

            labels = dates.map({ $0.toString })
        case .custom:
            let range = Calendar.current.numberOfDaysBetween(transactionVM.startDate.startOfDay, and: transactionVM.endDate.startOfDay)
            
            if range > 62 {
                startDate = transactionVM.startDate.startOfMonth().startOfDay
                
                while startDate < transactionVM.endDate.endOfMonth().endOfDay {
                    dates.append(startDate)
                    startDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate)!
                }
                
                monthlyData = [Double](repeating: 0.0, count: dates.count)
                
                for transaction in transactionVM.filteredTransactions {
                    let calendarDate = Calendar.current.dateComponents([.hour], from: transaction.date)
                    
                    if selectedTypes.contains(transaction.type), let index = dates.firstIndex(of: transaction.date.startOfMonth().startOfDay) {
                        monthlyData[index] += transaction.amount?.doubleValue ?? 0
                        categoryData[transaction.category, default: 0] += transaction.amount?.doubleValue ?? 0
                        timeArray[calendarDate.hour!] += transaction.amount?.doubleValue ?? 0
                    }
                }
            } else {
                monthlyData = [Double](repeating: 0.0, count: range)
                
                while startDate < transactionVM.endDate.startOfDay {
                    dates.append(startDate)
                    startDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
                }
                
                if !dates.contains(transactionVM.endDate.startOfDay){
                    dates.append(transactionVM.endDate.startOfDay)
                }
                
                for transaction in transactionVM.filteredTransactions {
                    let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: transaction.date.startOfDay)!
                    
                    let calendarDate = Calendar.current.dateComponents([.hour], from: transaction.date)
                    
                    if selectedTypes.contains(transaction.type), let index = dates.firstIndex(of: nextDate) {
                        monthlyData[index] += transaction.amount?.doubleValue ?? 0
                        categoryData[transaction.category, default: 0] += transaction.amount?.doubleValue ?? 0
                        timeArray[calendarDate.hour!] += transaction.amount?.doubleValue ?? 0
                    }
                }
            }
            
            labels = dates.map({ $0.toShortString })
        case .yearly:
            monthlyData = [Double](repeating: 0.0, count: 12)
            
            while startDate < transactionVM.endDate.startOfDay {
                dates.append(startDate)
                startDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate)!
            }
            
            for transaction in transactionVM.filteredTransactions {
                let calendarDate = Calendar.current.dateComponents([.hour], from: transaction.date)
                if selectedTypes.contains(transaction.type), let index = dates.firstIndex(of: transaction.date.startOfMonth().startOfDay) {
                    monthlyData[index] += transaction.amount?.doubleValue ?? 0
                    categoryData[transaction.category, default: 0] += transaction.amount?.doubleValue ?? 0
                    timeArray[calendarDate.hour!] += transaction.amount?.doubleValue ?? 0
                }
            }
            
            labels = dates.map({ $0.getMonthString })
        }
        
        let max = monthlyData.max() ?? 1

        let percentData = monthlyData.map({ $0/(max == 0 ? 1 : max) })
    
        
        categoryData.sort {
            $0.value > $1.value
        }
        
        timeArray.enumerated().forEach({ index, item in
            let date = Calendar.current.date(bySetting: .hour, value: index, of: Date().startOfDay)!
            
            if item > 0 {
                timeData[date, default: 0] = item
            }
        })
        
        timeData.sort {
            $0.value > $1.value
        }
        
        withAnimation {
            chartData = percentData
        }
        
        transactionData = monthlyData
        
//        var convertedCategoryData: OrderedDictionary<Category, Double> = [:]
//
//        for (key, value) in categoryData {
//            if let foundCategory = categories.first(where: { $0.id.uuidString == key }) {
//                convertedCategoryData[foundCategory] = value
//            } else {
//                convertedCategoryData[Category(categoryHeader: "", name: "", image: "", order: 0, type: .expense, color: ""), default: 0.0] += value
//            }
//        }
        
        self.categoryData = categoryData
        self.timeData = timeData
    }
}

enum InsightPeriod: String, CaseIterable {
    case monthly = "Monthly"
    case weekly = "Weekly"
}

extension Calendar {
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from)
        let toDate = startOfDay(for: to)
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate)
        
        return numberOfDays.day! + 1 // <1>
    }
}
