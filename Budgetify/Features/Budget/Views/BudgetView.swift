//
//  BudgetView.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 12/11/22.
//

import SwiftUI
import FirebaseAnalyticsSwift
import Charts

struct BudgetView: View {
    @EnvironmentObject var vm: BudgetViewModel
    @EnvironmentObject var categoryVM: CategoryViewModel
    
    @EnvironmentObject var tm: ThemeManager
    
    @AppStorage("currencyCode", store: .grouped) var currencyCode: String = ""
    @AppStorage("selectedPhotoURL", store: .grouped) var selectedPhotoURL: URL?
    
    @ObservedObject var sm = SettingsManager.shared
    
    var body: some View {
        ZStack {
            tm.selectedTheme.backgroundColor
                .ignoresSafeArea()
            
            VStack {
                header
                    .unredacted()
                
                ScrollView(showsIndicators: false) {
                    ForEach($vm.budgets) { $budget in
                        budgetRow(budget: budget)
                    }
                }
                .refreshable {
                    Task {
                        await vm.getBudgets()
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .redacted(reason: vm.loading ? .placeholder: [])
            .sheet(isPresented: $vm.isBudgetSheetShown) {
                BudgetSheetView(budget: Budget(image: "house", order: (vm.budgets.map({$0.order}).max() ?? 0) + 1), parentVM: vm, transactionService: TransactionService())
                    .ignoresSafeArea()
            }
        }
        .analyticsScreen(name: self.pageTitle, class: self.pageTitle)
    }
}

struct BudgetView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetView()
            .withPreviewEnvironmentObjects()
    }
}

extension BudgetView {
    var header: some View {
        HStack {
            Text("Budgets")
                .font(.largeTitle)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button(action: {
                vm.isBudgetSheetShown.toggle()
            }, label: {
                Image(systemName: "plus")
            })
            
            Rectangle()
                .foregroundColor(Color(uiColor: .tertiaryLabel))
                .frame(width: 1, height: 20)
                
            NavigationLink(destination: AccountView()) {
                ProfilePictureView(photoURL: selectedPhotoURL, dimensions: 25)
            }
        }
        .foregroundColor(tm.selectedTheme.primaryColor)
    }
    
    func budgetRow(budget: Budget) -> some View {
        GeometryReader { proxy in
            NavigationLink(destination: BudgetDetailView(budget: budget, parentVM: vm)) {
                HStack {
                    
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            CustomIconView(imageName: budget.image)
                            Text(budget.name)
                                .fontWeight(.medium)
                        }
                        
                        HStack {
                            HStack(spacing: 5) {
                                Text(sm.currencySymbols ? currencyCode.currencySymbol : currencyCode)
                                    .foregroundColor(tm.selectedTheme.tertiaryLabel)
                                
                                AmountTextView((((budget.budgetAmount ?? 0) + budget.carryoverAmount) - budget.spentAmount).toString)
                                    .font(.title.weight(.medium))
                            }
                            .font(.title)
                                    
                           
                            VStack {
                                Spacer()
                            
                                Text(budget.overbudget ? "over" : "left")
                                        .fontWeight(.medium)
                                        .font(.subheadline)
                                        .foregroundColor(budget.overbudget ? .red : tm.selectedTheme.secondaryColor)
                            }
                            
                            Spacer()
                            
                            VStack {
                                Spacer()
                                
                                AmountTextView(((budget.budgetAmount ?? 0) + budget.carryoverAmount).toString)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(tm.selectedTheme.secondaryColor)
                            }
                        }
                        
                        ProgressView(value: budget.budgetProgress > 1 ? 1 : budget.budgetProgress)
                                .padding(.bottom, 10)
                                .tint(tm.selectedTheme.primaryColor)
                        
                    }
                    
                    Spacer()
                    
                }
                .foregroundColor(tm.selectedTheme.primaryLabel)
            }
        }
        .frame(height: 80)
    }
}
