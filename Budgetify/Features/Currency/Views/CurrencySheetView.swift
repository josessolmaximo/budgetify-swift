//
//  CurrencySheetView.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 10/12/22.
//

import SwiftUI
import FirebaseAnalyticsSwift

struct CurrencySheetView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var vm = CurrencySheetViewModel()
    
    @EnvironmentObject var tm: ThemeManager
    
    @AppStorage("currencyCode", store: .grouped) var currencyCode: String = ""
    @AppStorage("localeId", store: .grouped) var localeId: String = ""
    
    var body: some View {
        ZStack {
            tm.selectedTheme.backgroundColor
                .ignoresSafeArea()
            
            VStack {
                ScrollView {
                    LazyVStack {
                        ForEach(vm.currencies.filter({
                            vm.searchText.isEmpty ? true :
                            $0.name.lowercased().contains(vm.searchText.lowercased())
                            ||
                            $0.code.lowercased().contains(vm.searchText.lowercased())
                        }), id: \.self) { currency in
                            
                            currencyRow(currency: currency)
                                .onTapGesture {
                                    currencyCode = currency.code
                                    localeId = currency.identifier
                                }
                            
                            Divider()
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .searchable(text: $vm.searchText, placement: .navigationBarDrawer(displayMode: .always))
            .navigationTitle("Currencies")
            .modifier(CustomBackButtonModifier(dismiss: dismiss))
        }
        .analyticsScreen(name: self.pageTitle, class: self.pageTitle)
    }
}

struct CurrencySheetView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencySheetView()
            .withPreviewEnvironmentObjects()
    }
}

extension CurrencySheetView {
    func currencyRow(currency: Currency) -> some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
            
            HStack {
                Text(currency.code.uppercased())
                    .fontWeight(.semibold)
                    .frame(width: 40, alignment: .leading)
                    .padding(.leading, 10)
                    .minimumScaleFactor(0.01)
                
                Text(currency.name)
                    .lineLimit(1)
                
                Spacer()
                
                if currency.code.currencySymbol != currency.code.uppercased() {
                    Text(currency.code.currencySymbol)
                        .padding(.trailing, 10)
                }
            }
            .frame(height: 30)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(tm.selectedTheme.tertiaryLabel, lineWidth: 2)
                    .opacity(currency.code == currencyCode ? 1 : 0)
                    .padding(.vertical, -2.5)
            )
        }
    }
}
