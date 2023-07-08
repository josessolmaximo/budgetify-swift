//
//  BudgetSheetView.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 28/11/22.
//

import SwiftUI
import OrderedCollections
import FirebaseAnalyticsSwift

struct BudgetSheetView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var categoryVM: CategoryViewModel
    @EnvironmentObject var tm: ThemeManager
    
    @StateObject var vm: BudgetSheetViewModel
    
    @StateObject var em = ErrorManager.shared
    
    @AppStorage("currencyCode", store: .grouped) var currencyCode: String = ""
    
    @ObservedObject var sm = SettingsManager.shared
    
    let everyType: [BudgetPeriodType: Range<Int>] = [.daily: 1..<32, .weekly: 1..<53, .monthly: 1..<13]
    var periodType: [BudgetPeriodType: String] = [.daily: "day", .monthly : "month", .weekly: "week"]
    
    let budgetExists: Bool
    let budgetStartDate: Date
    let onDismiss: ((Budget) -> Void)?
    
    init(budget: Budget, parentVM: BudgetSheetProtocol, transactionService: TransactionServiceProtocol, onDismiss: ((Budget) -> Void)? = nil) {
        self._vm = StateObject(wrappedValue: BudgetSheetViewModel(budget: budget, parentVM: parentVM, transactionService: transactionService))
        
        self.budgetExists = parentVM.budgets.contains(where: { $0.id == budget.id })
        self.budgetStartDate = Calendar.current.date(byAdding: .second, value: 1, to: budget.startDate)!
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 5) {
                    amount
                    
                    IconPickerField(text: $vm.budget.name, image: $vm.budget.image)
                        .padding(.horizontal)
                    
                    HStack {
                        Text("Balance Carryover")
                        
                        Button(action: {
                            vm.isCarryoverPopoverShown.toggle()
                        }, label: {
                            Image(systemName: "info.circle")
                        })
                        .foregroundColor(tm.selectedTheme.primaryLabel)
                        .alwaysPopover(isPresented: $vm.isCarryoverPopoverShown) {
                            Text("Remaining balance of a period will be carried\nover to the next period")
                                .font(.subheadline)
                                .padding()
                        }
                        
                        Spacer()
                        
                        Checkbox(isChecked: $vm.budget.carryover)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    if vm.parentVM.budgets.contains(vm.budget) {
                        HStack {
                            Text("Spent Amount")
                            
                            TextField("", value: $vm.budget.spentAmount, format: .number)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(tm.selectedTheme.primaryLabel)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .redacted(reason: sm.amountsVisible ? [] : .placeholder)
                                .disabled(!sm.amountsVisible)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        HStack {
                            Text("Carryover Amount")
                            
                            TextField("", value: $vm.budget.carryoverAmount, format: .number)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(tm.selectedTheme.primaryLabel)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .redacted(reason: sm.amountsVisible ? [] : .placeholder)
                                .disabled(!sm.amountsVisible)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        HStack {
                            Text("Order")
                            
                            TextField("", value: $vm.budget.order, format: .number)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(tm.selectedTheme.primaryLabel)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                    
                    periodPicker
                    
                    if vm.budget.period.type == .monthly {
                        customPeriodPicker
                    }
                    
                    VStack {
                        if budgetExists {
                            DatePicker("Start Date",
                                       selection: Binding(get: {
                                Calendar.current.date(byAdding: .second, value: 1, to: vm.budget.startDate)!
                            }, set: {
                                vm.budget.startDate = $0.startOfDay
                                vm.configureEndDate()
                            })
                                       , in: budgetStartDate...
                                       , displayedComponents: .date)
                        } else {
                            DatePicker("Start Date",
                                       selection: Binding(get: {
                                vm.budget.startDate
                            }, set: {
                                vm.budget.startDate = $0.startOfDay
                                vm.configureEndDate()
                            })
                                       , displayedComponents: .date)
                        }
                        
                        if vm.budget.period.type == .custom || budgetExists  {
                            DatePicker("End Date", selection: Binding(get: {
                                vm.budget.endDate
                            }, set: {
                                vm.budget.endDate = $0.endOfDay
                            })
                                       , in: vm.budget.startDate...
                                       , displayedComponents: .date)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 5)
                    .font(.system(size: 17, weight: .medium))
                    
                    categories
                }
                
                if vm.isCarryoverPopoverShown {
                    viewBlocker
                }
            }
            .onAppear {
                if !budgetExists {
                    vm.configureEndDate()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: vm.budget.period, perform: { _ in
                vm.configureEndDate()
            })
            .alert("Validation Error", isPresented: $vm.isErrorAlertShown) {
                Button("OK") {
                    vm.isErrorAlertShown = false
                }
            } message: {
                Text(vm.errorAlertMessage ?? "An unknown error occured. Please try again.")
            }
            .alert(isPresented: $vm.isDeleteAlertShown, content: {
                Alert(
                    title: Text("Delete Budget"),
                    message: Text("Are you sure you want to delete this budget? This action is permanent and cannot be undone."),
                    primaryButton: .destructive(Text("Delete"), action: {
                        Task {
                            await vm.deleteBudget()
                        }
                    }),
                    secondaryButton: .cancel(Text("Cancel")))
            })
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    ZStack {
                        if !vm.loading {
                            Button("Cancel") {
                                dismiss()
                            }
                            .foregroundColor(tm.selectedTheme.tintColor)
                        }
                        
                        if vm.isCarryoverPopoverShown {
                            viewBlocker
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    ZStack {
                        if vm.parentVM.budgets.contains(vm.budget) && !vm.loading {
                            Button(role: .destructive) {
                                vm.isDeleteAlertShown.toggle()
                            } label: {
                                Text("Delete")
                            }
                            .foregroundColor(.red)
                        }
                        
                        if vm.isCarryoverPopoverShown {
                            viewBlocker
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    ZStack {
                        let isUpdate = vm.parentVM.budgets.contains(where: { $0 == vm.budget })
                        
                        if vm.loading {
                            ProgressView()
                                .tint(tm.selectedTheme.tintColor)
                        } else {
                            Button(isUpdate ? "Save" : "Add") {
                                if isUpdate {
                                    Task {
                                        await vm.updateBudget()
                                    }
                                } else {
                                    if PremiumManager.shared.isPremium || vm.parentVM.budgets.count < ConfigManager.shared.paywallLimits["budgets"]! {
                                        Task {
                                            await vm.createBudget()
                                        }
                                    } else {
                                        ErrorManager.shared.premiumError = true
                                    }
                                }
                            }
                            .foregroundColor(tm.selectedTheme.tintColor)
                        }
                        
                        if vm.isCarryoverPopoverShown {
                            viewBlocker
                        }
                    }
                }
                
                ToolbarItem(placement: .keyboard) {
                    KeyboardToolbar()
                }
            }
        }
        .onChange(of: vm.shouldSheetDismiss) { value in
            if value {
                dismiss()
                
                if budgetExists {
                    onDismiss?(vm.budget)
                }
            }
        }
        .analyticsScreen(name: self.pageTitle, class: self.pageTitle)
        .errorAlert(error: $em.serviceError)
        .errorAlert(error: $em.validationError)
        .sheet(isPresented: $em.premiumError, content: {
            PremiumSheetView()
        })
    }
}

struct BudgetSheetView_Previews: PreviewProvider {
    static var previews: some View {
        let parentVM = BudgetViewModel(budgetService: MockBudgetService())
        let mockBudget = Budget(image: "house", categories: defaultCategories.map({$0.id.uuidString}))
        
        BudgetSheetView(budget: mockBudget, parentVM: parentVM, transactionService: MockTransactionService())
            .withPreviewEnvironmentObjects()
    }
}

extension BudgetSheetView {
    @ViewBuilder
    var categories: some View {
        HStack {
            Text("CATEGORIES")
                .fontWeight(.semibold)
            
            Spacer()
            
            let areAllCategoriesSelected = vm.budget.categories == categoryVM.allCategories.map({$0.id.uuidString})
            
            Button(action: {
                if areAllCategoriesSelected {
                    vm.budget.categories = []
                } else {
                    vm.budget.categories = categoryVM.allCategories.map({$0.id.uuidString})
                }
            }, label: {
                if areAllCategoriesSelected {
                    Text("Unselect All")
                } else {
                    Text("Select All")
                }
                
            })
            .padding(.trailing, 2)
        }
        .font(.subheadline)
        .frame(height: 30)
        .padding(.horizontal)
        
        Divider()
        
        ScrollView {
            let sortedCategories = categoryVM.categories.sorted(by: { category1, category2 in
                categoryVM.categoryOrder.firstIndex(of: category1.key) ??
                categoryVM.categoryOrder.count < categoryVM.categoryOrder.firstIndex(of: category2.key) ??
                categoryVM.categoryOrder.count
            }).map({ $0.key })
            
            ForEach(sortedCategories.filter({ section in
                return !(categoryVM.categories[section]?.filter({$0.type == .expense}).isEmpty ?? false)
            })) { section in
                let validCategories = categoryVM.categories[section]?.filter({$0.type == .expense})
                
                HStack {
                    Text(section.uppercased())
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                }
                
                VStack(spacing: 10) {
                    ForEach(Array(stride(from: 0, to: validCategories?.count ?? 0, by: 4)), id: \.self) { index in
                        HStack {
                            categoryCell(categories: validCategories ?? [], index: index)
                            categoryCell(categories: validCategories ?? [], index: index + 1)
                            categoryCell(categories: validCategories ?? [], index: index + 2)
                            categoryCell(categories: validCategories ?? [], index: index + 3)
                        }
                    }
                }
                .padding(.bottom, 5)
            }
            .padding(.top, 10)
            .padding(.horizontal)
        }
    }
    
    var customPeriodPicker: some View {
        HStack {
            Image(systemName: "clock.arrow.2.circlepath")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
            Menu {
                Menu {
                    ForEach(1...28, id: \.self) { num in
                        Button(action: {
                            vm.budget.period.amount = num
                            vm.budget.period.customType = .first
                        }, label: {
                            Text(vm.numberFormatter.string(from: num as NSNumber)!)
                        })
                    }
                } label: {
                    Text("On the _ day of the month")
                }
                
                Menu {
                    ForEach(1...28, id: \.self) { num in
                        Button(action: {
                            vm.budget.period.amount = num
                            vm.budget.period.customType = .last
                        }, label: {
                            Text(vm.numberFormatter.string(from: num as NSNumber)!)
                        })
                    }
                } label: {
                    Text("On the last _ day of the month")
                }
                
            } label: {
                if vm.budget.period.customType == .first {
                    Text("On the \(vm.numberFormatter.string(from: vm.budget.period.amount as NSNumber)!) day of the month")
                        .fontWeight(.medium)
                        .foregroundColor(tm.selectedTheme.tintColor)
                        .frame(width: 300, alignment: .leading)
                } else if vm.budget.period.customType == .last {
                    Text(vm.budget.period.amount == 1 ? "On the last day of the month" : "On the \(vm.numberFormatter.string(from: vm.budget.period.amount as NSNumber)!) to last day of the month")
                        .fontWeight(.medium)
                        .foregroundColor(tm.selectedTheme.tintColor)
                        .frame(width: 300, alignment: .leading)
                }
            }
            .frame(alignment: .leading)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
    
    var periodPicker: some View {
        HStack {
            Image(systemName: "calendar.badge.clock")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
            Menu {
                Picker("", selection: $vm.budget.period.type) {
                    ForEach(BudgetPeriodType.allCases, id: \.self) {
                        Text($0.rawValue)
                            .tag($0)
                    }
                }
            } label: {
                Text(vm.budget.period.type.rawValue)
                    .fontWeight(.medium)
                    .foregroundColor(tm.selectedTheme.tintColor)
            }
            
            Spacer()
            
            if vm.budget.period.type != .monthly && vm.budget.period.type != .custom {
                Menu {
                    Picker("", selection: $vm.budget.period.amount) {
                        ForEach(everyType[vm.budget.period.type]!, id: \.self) { num in
                            if num == 1 {
                                Text("Every\(vm.budget.period.type == .daily ? "" : " ")\(periodType[vm.budget.period.type]!)")
                            } else {
                                Text("Every \(num) \(periodType[vm.budget.period.type]!)s")
                            }
                        }
                    }
                } label: {
                    if vm.budget.period.amount == 1 {
                        Text("Every\(vm.budget.period.type == .daily ? "" : " ")\(periodType[vm.budget.period.type]!)")
                            .fontWeight(.medium)
                            .foregroundColor(tm.selectedTheme.tintColor)
                    } else {
                        Text("Every \(vm.budget.period.amount) \(periodType[vm.budget.period.type]!)s")
                            .fontWeight(.medium)
                            .foregroundColor(tm.selectedTheme.tintColor)
                            .frame(width: 200, alignment: .trailing)
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
    
    var amount: some View {
        HStack {
            let budgetExists = vm.parentVM.budgets.contains(where: { $0.id == vm.budget.id })
            
            Text(sm.currencySymbols ? currencyCode.currencySymbol : currencyCode)
                .foregroundColor(tm.selectedTheme.tertiaryLabel)
            
            TextField("0", value: $vm.budget.budgetAmount, format: .number)
                .font(.system(size: 34, weight: .semibold))
                .foregroundColor(tm.selectedTheme.primaryLabel)
                .keyboardType(.decimalPad)
                .redacted(reason: !budgetExists || sm.amountsVisible ? [] : .placeholder)
                .disabled(!sm.amountsVisible && budgetExists)
        }
        .font(.largeTitle)
        .padding(.horizontal)
    }
    
    func categoryCell(categories: [Category], index: Int) -> some View {
        ZStack {
            VStack {
                
                if index < categories.count {
                    let isSelected = vm.budget.categories.filter({$0 == categories[index].id.uuidString}).count > 0
                    
                    CustomIconView(imageName: categories[index].image)
                        .foregroundColor(isSelected ? categories[index].color.stringToColor() : tm.selectedTheme.secondaryColor)
                    
                    Text(categories[index].name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.5)
                        .foregroundColor(isSelected ? categories[index].color.stringToColor() : tm.selectedTheme.secondaryColor)
                    
                    Spacer()
                }
            }
            .onTapGesture {
                if let index = vm.budget.categories.firstIndex(of: categories[index].id.uuidString) {
                    vm.budget.categories.remove(at: index)
                } else {
                    vm.budget.categories.append(categories[index].id.uuidString)
                }
            }
            
            Color.clear
        }
    }
    
    var viewBlocker: some View {
        Color.white.opacity(0.00001)
            .contentShape(Rectangle())
            .onTapGesture {
                vm.isCarryoverPopoverShown = false
            }
    }
}
