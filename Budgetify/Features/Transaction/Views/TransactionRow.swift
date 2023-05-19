//
//  TransactionRow.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 14/02/23.
//

import SwiftUI

struct TransactionRow: View {
    @AppStorage("selectedPhotoURL", store: .grouped) var selectedPhotoURL: URL?
    @AppStorage("photoURL", store: .grouped) var photoURL: URL?
    
    @AppStorage("userId", store: .grouped) var userId: String = ""
    
    @AppStorage("currencyCode", store: .grouped) var currencyCode: String = ""
    
    @EnvironmentObject var categoryVM: CategoryViewModel
    @EnvironmentObject var walletVM: WalletViewModel
    
    @EnvironmentObject var tm: ThemeManager
    
    @ObservedObject var sm = SettingsManager.shared
    
    @Binding var selectedTransaction: Transaction?
    
    let transaction: Transaction
    
    let mode: RowMode
    
    enum RowMode {
        case normal
        case shortcut
    }
    
    var body: some View {
        ZStack {
            let category = categoryVM.getCategoryById(id: transaction.category)
            let originWallet = walletVM.getWalletById(id: transaction.originWallet)
            let destinationWallet = walletVM.getWalletById(id: transaction.destinationWallet)
            
            HStack {
                Rectangle()
                    .frame(width: 3, height: 40)
                    .foregroundColor(transaction.type == .transfer ? tm.selectedTheme.secondaryLabel : category?.color.stringToColor() ?? tm.selectedTheme.secondaryLabel)
                
                ZStack {
                    if transaction.type == .transfer {
                        CustomIconView(imageName: "arrow.left.arrow.right", dimensions: 20)
                            .foregroundColor(tm.selectedTheme.secondaryLabel)
                            .padding(.leading, 5)
                    } else {
                        CustomIconView(imageName: category?.image ?? "tray", dimensions: 20)
                            .redacted(reason: category == nil ? .placeholder : [])
                            .foregroundColor(category?.color.stringToColor() ?? tm.selectedTheme.secondaryLabel)
                            .padding(.leading, 5)
                    }
                }
                
                VStack(alignment: .leading, spacing: 0){
                    HStack {
                        if transaction.type == .transfer {
                            Text("Transfer")
                                .fontWeight(.semibold)
                                .foregroundColor(tm.selectedTheme.primaryLabel)
                        } else {
                            Text(category?.name ?? "Unknown")
                                .fontWeight(.semibold)
                                .redacted(reason: category == nil ? .placeholder : [])
                                .foregroundColor(tm.selectedTheme.primaryLabel)
                        }
                    }
                    
                    HStack(spacing: 5) {
                        CustomIconView(imageName: originWallet?.image ?? "circle.slash", dimensions: 15)
                            .redacted(reason: originWallet == nil ? .placeholder : [])
                        
                        if transaction.type == .transfer {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 12))
                            
                            CustomIconView(imageName: destinationWallet?.image ?? "circle.slash", dimensions: 15)
                                .redacted(reason: destinationWallet == nil ? .placeholder : [])
                        }
                        
                        if transaction.createdBy != userId &&
                            !transaction.creatorPhoto.isEmpty &&
                            !transaction.createdBy.isEmpty
                        {
                            Divider()
                                .padding(.vertical, 5)
                            
                            ProfilePictureView(photoURL: URL(string: transaction.creatorPhoto), dimensions: 15)
                        }
                        
                        if transaction.recurring.type != .none {
                            Divider()
                                .padding(.vertical, 5)
                            
                            Image(systemName: "arrow.2.squarepath")
                                .font(.system(size: 12))
                                .foregroundColor(tm.selectedTheme.secondaryColor)
                        }
                        
                        Divider()
                            .padding(.vertical, 5)
                        
                        
                        Text(transaction.date.formatted(date: .omitted, time: .shortened))
                            .fontWeight(.medium)
                            .font(.system(size: 12))
                            .foregroundColor(tm.selectedTheme.secondaryColor)
                            .redacted(reason: mode == .shortcut ? .placeholder : [])
                        
                        if !transaction.note.isEmpty {
                            Divider()
                                .padding(.vertical, 5)
                            
                            Text(transaction.note)
                                .font(.system(size: 12))
                                .foregroundColor(tm.selectedTheme.secondaryLabel)
                        }
                        
                        
                    }
                }
                .padding(.leading, 5)
                
                Spacer()
                
                HStack(spacing: 3) {
                    Text(sm.currencySymbols ? currencyCode.currencySymbol : currencyCode)
                        .foregroundColor(tm.selectedTheme.tertiaryLabel)
                    
                    AmountTextView(transaction.amount?.toString ?? "")
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(category?.type == .expense ? tm.selectedTheme.primaryColor : category?.type == .income ? .green : tm.selectedTheme.secondaryColor)
            }
            .frame(height: 40)
            .padding(.horizontal)
            
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedTransaction = transaction
                }
        }
    }
}

struct TransactionRow_Previews: PreviewProvider {
    static var previews: some View {
        TransactionRow(selectedTransaction: .constant(nil), transaction: Transaction(category: "", originWallet: "", destinationWallet: ""), mode: .normal)
            .withPreviewEnvironmentObjects()
    }
}
