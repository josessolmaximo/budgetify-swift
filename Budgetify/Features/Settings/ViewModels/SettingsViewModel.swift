//
//  SettingsViewModel.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 19/03/23.
//

import UIKit
import CodableCSV

class SettingsViewModel: ObservableObject {
    let transactions: [TransactionCSV] = [
        .init(date: Date(), amount: 100, type: "Expense", category: "Food", originWallet: "Cash", destinationWallet: "Cash", note: "", location: "")
    ]
    
    func exportCSV(transactionVM: TransactionViewModel, categoryVM: CategoryViewModel, walletVM: WalletViewModel) async {
        let categories = await categoryVM.allCategories
        let wallets = await walletVM.wallets
        
        let transactionsCSV = await transactionVM.unfilteredTransactions.map { transaction in
            let category = categories.first(where: { $0.id.uuidString == transaction.category })
            let originWallet = wallets.first(where: { $0.id.uuidString == transaction.originWallet })
            let destinationWallet = wallets.first(where: { $0.id.uuidString == transaction.destinationWallet })
            
            return TransactionCSV(
                date: transaction.date,
                amount: transaction.amount ?? 0,
                type: transaction.type.rawValue,
                category: category?.name ?? (transaction.type == .transfer ? "Transfer" : "Unknown"),
                originWallet: originWallet?.name ?? "Unknown",
                destinationWallet: transaction.type == .transfer ? (destinationWallet?.name ?? "Unknown") : "",
                note: transaction.note,
                location: transaction.location.name)
        }
        
        let csvString = convertToCSV(data: transactionsCSV)
        
        let fileManager = FileManager.default
        
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileName = "transactions-from-\(await transactionVM.startDate.formatAs(.dateSeperatedByHyphen))-to-\(await transactionVM.endDate.formatAs(.dateSeperatedByHyphen))"
            
            let fileURL = documentDirectory.appendingPathComponent("\(fileName).csv")
            
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            
            let activityVC = await UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            
            await UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
        } catch {
            Logger.e("Error exporting CSV file: \(error.localizedDescription)")
        }
    }
    
    func convertToCSV(data: [TransactionCSV]) -> String {
        var csvString = ""
        
        let headerRow = TransactionCSV.CodingKeys.allCases.map { $0.rawValue }
        csvString += headerRow.joined(separator: ",") + "\n"
        
        let dateFormatter = ISO8601DateFormatter()
        
        for transaction in data {
            let dateStr = dateFormatter.string(from: transaction.date)
            let amountStr = "\(transaction.amount)"
            let typeStr = transaction.type
            let categoryStr = transaction.category
            let originWalletStr = transaction.originWallet
            let destinationWalletStr = transaction.destinationWallet
            let noteStr = transaction.note
            let locationStr = transaction.location
            
            let row = [dateStr, amountStr, typeStr, categoryStr, originWalletStr, destinationWalletStr, noteStr, locationStr]
            csvString += row.joined(separator: ",") + "\n"
        }
        
        return csvString
    }
}
