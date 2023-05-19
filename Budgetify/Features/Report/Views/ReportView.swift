//
//  InsightView.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 28/11/22.
//

import SwiftUI
import Charts
import FirebaseAnalyticsSwift

struct ReportView: View {
    @StateObject var vm = ReportViewModel()
    
    @EnvironmentObject var transactionVM: TransactionViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    @EnvironmentObject var categoryVM: CategoryViewModel
    @EnvironmentObject var walletVM: WalletViewModel
    @EnvironmentObject var tm: ThemeManager
    
    @AppStorage("currencyCode", store: .grouped) var currencyCode: String = ""
    @AppStorage("localeId", store: .grouped) var localeId: String = ""
    @AppStorage("selectedPhotoURL", store: .grouped) var selectedPhotoURL: URL?
    
    @ObservedObject var sm = SettingsManager.shared
    
    var body: some View {
        ZStack {
            tm.selectedTheme.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                    .unredacted()
                
                periodChanger
                    .unredacted()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        
                        chartView
                            .padding(.top, 5)
                        
                        categoryView
                        
                        timeView
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                }
            }
            .redacted(reason: transactionVM.loading ? .placeholder : [])
            .onTapGesture {
                vm.selectedLabel = nil
            }
            .onAppear {
                vm.prevIncomeSelected = transactionVM.query.transactionType[TransactionType.income] ?? true
                vm.prevExpenseSelected = transactionVM.query.transactionType[TransactionType.expense] ?? true
                vm.prevTransferSelected = transactionVM.query.transactionType[TransactionType.transfer] ?? true
                
                transactionVM.query.transactionType[TransactionType.expense] = true
                transactionVM.query.transactionType[TransactionType.income] = false
                transactionVM.query.transactionType[TransactionType.transfer] = false
                
                transactionVM.filterTransactions(transactions: transactionVM.unfilteredTransactions, wallets: walletVM.wallets, categories: categoryVM.allCategories)
                
                vm.configureChart(transactionVM: transactionVM, categories: categoryVM.allCategories)
            }
            .onDisappear {
                transactionVM.query.transactionType[TransactionType.income] = vm.prevIncomeSelected
                transactionVM.query.transactionType[TransactionType.expense] = vm.prevExpenseSelected
                transactionVM.query.transactionType[TransactionType.transfer] = vm.prevTransferSelected
                
                transactionVM.filterTransactions(transactions: transactionVM.unfilteredTransactions, wallets: walletVM.wallets, categories: categoryVM.allCategories)
            }
            .onChange(of: transactionVM.unfilteredTransactions, perform: { _ in
                vm.configureChart(transactionVM: transactionVM, categories: categoryVM.allCategories)
            })
            .onChange(of: transactionVM.filterType, perform: { value in
                transactionVM.changePeriodType(type: value)
            })
            .onChange(of: transactionVM.startDate) { _ in
                Task {
                    await transactionVM.getTransactions(wallets: walletVM.wallets, categories: categoryVM.allCategories)
                }
            }
            .onChange(of: transactionVM.endDate) { _ in
                Task {
                    await transactionVM.getTransactions(wallets: walletVM.wallets, categories: categoryVM.allCategories)
                }
            }
            .onChange(of: transactionVM.loading) { loading in
                if loading {
                    vm.chartData = vm.chartData.map({ _ in return 0})
                } else {
                    vm.configureChart(transactionVM: transactionVM, categories: categoryVM.allCategories)
                }
            }
            .sheet(isPresented: $vm.isSearchSheetShown) {
                SearchSheetView(isReport: true, onApply: {
                    vm.configureChart(transactionVM: transactionVM, categories: categoryVM.allCategories)
                })
            }
        }
        .analyticsScreen(name: self.pageTitle, class: self.pageTitle)
    }
}

struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        ReportView()
            .withPreviewEnvironmentObjects()
            .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
        
        ReportView()
            .withPreviewEnvironmentObjects()
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
        
    }
}

extension ReportView {
    var timeView: some View {
        VStack(spacing: 5) {
            HStack {
                Text("Time Period")
                    .font(.subheadline.weight(.medium))
                
                Spacer()
                
                if vm.timeData.count > 5 {
                    Button(action: {
                        vm.seeAllTime.toggle()
                    }, label: {
                        Text(vm.seeAllTime ? "Hide" : "See All")
                            .font(.subheadline.weight(.regular))
                    })
                }
            }
            .unredacted()
            
            Divider()
            
            ForEach(vm.seeAllTime ? Array(vm.timeData.keys) : Array(vm.timeData.keys.prefix(5)), id: \.self){ time in
                let hour = Calendar.current.dateComponents([.hour], from: time)
                let endTime = Calendar.current.date(bySettingHour: hour.hour ?? 0, minute: 59, second: 59, of: time)
                
                HStack {
                    Text("\(time.toHourAndMinute) - \(endTime?.toHourAndMinute ?? "")")
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .frame(width: 150, alignment: .leading)
                    Spacer()
                    
                    
                    HStack(spacing: 2.5){
                        Text(sm.currencySymbols ? currencyCode.currencySymbol : currencyCode)
                            .foregroundColor(tm.selectedTheme.tertiaryLabel)
                        
                        AmountTextView(vm.timeData[time]?.toString ?? "")
                            .lineLimit(1)
                            .minimumScaleFactor(0.9)
                    }
                    
                    Rectangle()
                        .frame(width: 1, height: 15)
                        .foregroundColor(tm.selectedTheme.tertiaryLabel)
                    
                    AmountTextView("\(((vm.timeData[time] ?? 0)/vm.timeData.values.reduce(0, +) * 100).toString)%")
                        .font(.system(size: 15, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)
                        .frame(width: 55, alignment: .trailing)
                        .foregroundColor(tm.selectedTheme.tertiaryLabel)
                }
                .padding(.vertical, 5)
                .font(.subheadline)
            }
            
            if !vm.seeAllTime && vm.timeData.count > 5 {
                let other = vm.timeData.values.count > 5 ? Array(vm.timeData.values.suffix(vm.timeData.count - 5)) : []
                
                HStack {
                    Text("Other")
                    
                    Spacer()
                    
                    HStack(spacing: 2.5){
                        Text(sm.currencySymbols ? currencyCode.currencySymbol : currencyCode)
                            .foregroundColor(tm.selectedTheme.tertiaryLabel)
                        AmountTextView(other.reduce(0, +).toString)
                            .lineLimit(1)
                            .minimumScaleFactor(0.9)
                    }
                    
                    Rectangle()
                        .frame(width: 1, height: 15)
                        .foregroundColor(tm.selectedTheme.tertiaryLabel)
                    
                    AmountTextView("\((other.reduce(0, +)/vm.timeData.values.reduce(0, +) * 100).toString)%")
                        .font(.system(size: 15, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)
                        .frame(width: 55, alignment: .trailing)
                        .foregroundColor(tm.selectedTheme.tertiaryLabel)
                }
                .padding(.vertical, 5)
                .font(.subheadline)
            }
        }
        .padding(.top, 10)
    }
    
    var header: some View {
        HStack {
            
            Text("Reports")
                .font(.largeTitle)
                .fontWeight(.semibold)
            
            Spacer()
            
            let isSearchActive = transactionVM.unfilteredTransactions != transactionVM.filteredTransactions
            
            Button(action: {
                vm.isSearchSheetShown.toggle()
            }, label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 17, weight: isSearchActive ? .semibold : .regular))
            })
            .foregroundColor(isSearchActive ? tm.selectedTheme.tintColor : tm.selectedTheme.primaryColor)
            
            Menu {
                Picker("", selection: $transactionVM.filterType) {
                    ForEach(FilterType.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
            } label: {
                Image(systemName: "calendar")
            }
            
            
            Rectangle()
                .foregroundColor(tm.selectedTheme.tertiaryLabel)
                .frame(width: 1, height: 20)
            
            NavigationLink(destination: AccountView()) {
                ProfilePictureView(photoURL: selectedPhotoURL, dimensions: 25)
            }
            
        }
        .padding(.horizontal)
        .foregroundColor(tm.selectedTheme.primaryColor)
    }
    
    var periodChanger: some View {
        HStack {
            Button(action: {
                transactionVM.changePeriod(change: .previous)
            }, label: {
                Image(systemName: "chevron.left")
            })
            
            Spacer()
            
            if transactionVM.filterType != .custom {
                Text(transactionVM.filterType == .yearly ?
                     transactionVM.startDate.getYearString
                     :
                        transactionVM.filterType == .monthly ?
                     transactionVM.startDate.getMonthString
                     :
                        transactionVM.filterType == .daily ?
                     "\(transactionVM.startDate.getDateAndMonthString)"
                     :
                        "\(transactionVM.startDate.getDateAndMonthString) - \(transactionVM.endDate.getDateAndMonthString)"
                )
                .font(.system(size: 16))
                .fontWeight(.medium)
                .foregroundColor(tm.selectedTheme.secondaryColor)
                .padding(.horizontal, 5)
            } else {
                HStack(spacing: 0) {
                    CustomDatePicker(date: $transactionVM.startDate)
                    Spacer()
                    Rectangle()
                        .foregroundColor(tm.selectedTheme.secondaryColor)
                        .frame(width: 10, height: 1)
                        .padding(.horizontal, 10)
                    Spacer()
                    CustomDatePicker(date: $transactionVM.endDate, alignment: .forceRightToLeft)
                }
            }
            
            Spacer()
            
            Button(action: {
                transactionVM.changePeriod(change: .next)
            }, label: {
                Image(systemName: "chevron.right")
            })
        }
        .frame(height: 40)
        .padding(.horizontal)
        .foregroundColor(tm.selectedTheme.primaryColor)
    }
    
    var categoryView: some View {
        HStack {
            
            
            VStack(spacing: 5) {
                HStack {
                    Text("Categories")
                        .font(.subheadline.weight(.medium))
                    
                    Spacer()
                    
                    if vm.categoryData.count > 5 {
                        Button(action: {
                            vm.seeAllCategories.toggle()
                        }, label: {
                            Text(vm.seeAllCategories ? "Hide" : "See All")
                                .font(.subheadline.weight(.regular))
                        })
                    }
                    
                }
                .unredacted()
                
                Divider()
                
                ForEach(vm.seeAllCategories ? Array(vm.categoryData.keys) : Array(vm.categoryData.keys.prefix(5)), id:\.self){ categoryId in
                    let category = categoryVM.getCategoryById(id: categoryId)
                    
                    HStack {
                        Rectangle()
                            .frame(width: 3, height: 30)
                            .foregroundColor(category?.color.stringToColor() ?? tm.selectedTheme.secondaryLabel)
                        
                        CustomIconView(imageName: category?.image ?? "", dimensions: 20)
                            .redacted(reason: category?.image == nil ? .placeholder : [])
                            .foregroundColor(category?.color.stringToColor() ?? tm.selectedTheme.secondaryLabel)
                            .padding(.horizontal, 2.5)
                        
                        Text(category?.name ?? "Unknown")
                            .fontWeight(.medium)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .redacted(reason: category == nil ? .placeholder : [])
                            
                        Spacer()
                        
                        HStack(spacing: 2.5){
                            Text(sm.currencySymbols ? currencyCode.currencySymbol : currencyCode)
                                .foregroundColor(tm.selectedTheme.tertiaryLabel)
                            
                            AmountTextView(vm.categoryData[categoryId]?.toString ?? "")
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        }
                        
                        Rectangle()
                            .frame(width: 1, height: 15)
                            .foregroundColor(tm.selectedTheme.tertiaryLabel)
                        
                        AmountTextView("\(((vm.categoryData[categoryId] ?? 0)/vm.categoryData.values.reduce(0, +) * 100).toString)%")
                            .font(.system(size: 15, weight: .semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.9)
                            .frame(width: 55, alignment: .trailing)
                            .foregroundColor(tm.selectedTheme.tertiaryLabel)
                    }
                    .font(.subheadline)
                    .padding(.vertical, 2.5)
                }
                
                if !vm.seeAllCategories && vm.categoryData.count > 5 {
                    HStack {
                        Rectangle()
                            .frame(width: 3, height: 30)
                            .foregroundColor(tm.selectedTheme.tertiaryLabel)
                        
                        CustomIconView(imageName: "tray", dimensions: 20)
                            .padding(.horizontal, 2.5)
                        
                        Text("Others")
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        let other = vm.categoryData.values.count > 5 ? Array(vm.categoryData.values.suffix(vm.categoryData.count - 5)) : []
                        
                        HStack(spacing: 2.5){
                            Text(sm.currencySymbols ? currencyCode.currencySymbol : currencyCode)
                                .foregroundColor(tm.selectedTheme.tertiaryLabel)
                            
                            AmountTextView(other.reduce(0, +).toString)
                        }
                        
                        Rectangle()
                            .frame(width: 1, height: 15)
                            .foregroundColor(tm.selectedTheme.tertiaryLabel)
                        
                        AmountTextView("\((other.reduce(0, +)/vm.categoryData.values.reduce(0,+) * 100).toString)%")
                            .font(.system(size: 15, weight: .semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.9)
                            .frame(width: 55, alignment: .trailing)
                            .foregroundColor(tm.selectedTheme.tertiaryLabel)
                    }
                    .font(.subheadline)
                    .padding(.vertical, 2.5)
                }
            }
        }
    }
    
    var chartView: some View {
        VStack(spacing: 0) {
            
            chartHeader
            
            chart
            
            GeometryReader { proxy in
                let actualImageSize = (proxy.size.width - CGFloat((vm.chartData.count - 1) * 3))/CGFloat(vm.chartData.count)
                let imageSize = actualImageSize > 7.5 ? 7.5 : actualImageSize
                let offset = (actualImageSize) * CGFloat(vm.selectedIndex) + CGFloat(3 * vm.selectedIndex)
                let boundaryX = proxy.frame(in: .global).minX + vm.labelOffset + (offset.isNaN ? 0 : offset) + vm.labelWidth + 5

                VStack(spacing: 5) {
                    Image(systemName: "arrowtriangle.up.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageSize.isInfinite ? 0 : imageSize, height: imageSize.isInfinite ? 0 : imageSize)
                        .foregroundColor(tm.selectedTheme.primaryColor)
                        .opacity(vm.selectedLabel == nil ? 0 : 1)
                    HStack {
                        Text(vm.selectedLabel ?? "")
                            .font(.caption)
                    }
                    .foregroundColor(Color("#929292"))
                    .offset(x: boundaryX > UIScreen.main.bounds.width ? UIScreen.main.bounds.width - boundaryX - 5 : 0)
                    .opacity(0)
                }
                .readSize { size in
                    vm.labelWidth = size.width
                    vm.labelOffset = -size.width/2 + actualImageSize/2
                }
                .offset(x: vm.labelOffset)
                .offset(x: offset.isNaN ? 0 : offset)

            }
            
            .foregroundColor(tm.selectedTheme.secondaryColor)
            .padding(.leading, 48)
            .padding(.top, 5)
        }
    }
    
    var chartHeader: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(vm.selectedLabel ?? "Total")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(tm.selectedTheme.primaryColor)
                    .unredacted()
                
                HStack(spacing: 3) {
                    Text(sm.currencySymbols ? currencyCode.currencySymbol : currencyCode)
                        .font(.system(size: 24))
                        .foregroundColor(tm.selectedTheme.tertiaryLabel)
                    
                    AmountTextView("\(vm.selectedLabel == nil ? vm.transactionData.reduce(0, +).toString : (vm.transactionData[vm.selectedIndex]).toString )")
                        .font(.system(size: 24, weight: .medium))
                        .redacted(reason: transactionVM.loading ? .placeholder : [])
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("Average / \(transactionVM.filterType == .daily ? "Hour" : transactionVM.filterType == .yearly ? "Month" : "Day")")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(tm.selectedTheme.primaryColor)
                    .unredacted()
                
                HStack(spacing: 3) {
                    Text(sm.currencySymbols ? currencyCode.currencySymbol : currencyCode)
                        .font(.system(size: 24))
                        .foregroundColor(tm.selectedTheme.tertiaryLabel)
                    
                    AmountTextView("\((vm.transactionData.reduce(0, +)/Double(vm.transactionData.count)).abbreviated)")
                        .font(.system(size: 24, weight: .medium))
                        .redacted(reason: transactionVM.loading ? .placeholder : [])
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
            }
        }
    }
    
    var chart: some View {
        HStack {
            ZStack(alignment: .trailing) {
                HStack {
                    Text("0")
                        .font(.subheadline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.3)
                }
                .offset(y: 65)

                HStack {
                    Text("\((vm.transactionData.max() ?? 0).abbreviated)")
                        .font(.subheadline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.3)
                }
                .offset(y: -65)

                let offsetOrNaN = 75 - (vm.chartData.reduce(0, +) / Double(vm.chartData.count)) * 150
                let offset = offsetOrNaN.isNaN ? -65 : offsetOrNaN
                
                HStack {
                    Text((vm.transactionData.reduce(0, +) / Double(vm.transactionData.count)).abbreviated)
                        .font(.subheadline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.3)
                }
                .offset(y: offset < -45 ? -45 : offset > 45 ? 45 : offset)
                .opacity(offset > 45 || offset < -45 || vm.chartData.isEmpty ? 0 : 1)
            }
            .frame(width: 40)
            .foregroundColor(tm.selectedTheme.secondaryColor)
            
            ZStack {
                HStack {
                    Chart(data: vm.chartData)
                        .chartStyle(
                            ColumnChartStyle(column: RoundedRectangle(cornerRadius: vm.chartData.count > 7 ? 2 : 5).foregroundColor(tm.selectedTheme.primaryColor), spacing: 3)
                        )
                        .frame(height: 150)
                }

                HStack {
                    Chart(data: vm.chartData.map({ _ in return 1.0 }))
                        .chartStyle(
                            ColumnChartStyle(column: RoundedRectangle(cornerRadius: vm.chartData.count > 7 ? 2 : 5).foregroundColor(tm.selectedTheme.primaryColor).opacity(0.1), spacing: 3)
                        )
                        .frame(height: 150)

                }
                
                let offset = 75 - (vm.chartData.reduce(0, +) / Double(vm.chartData.count)) * 150

                Rectangle()
                    .foregroundColor(tm.selectedTheme.backgroundColor)
                    .frame(height: 2)
                    .offset(y: offset.isNaN ? 0 : offset)

                HStack(spacing: 3) {
                    ForEach(Array(zip(vm.labels.indices, vm.labels)), id: \.0){ index, item in
                        GeometryReader { proxy in
                            VStack {
                                Rectangle()
                                    .redacted(reason: .placeholder)
                            }
                            .frame(width: proxy.size.width)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                vm.selectedLabel = item
                                vm.selectedIndex = index
                            }
                        }
                    }
                }
                .foregroundColor(.clear)
                .frame(height: 150)
            }
            
        }
        .padding(.top)
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}
