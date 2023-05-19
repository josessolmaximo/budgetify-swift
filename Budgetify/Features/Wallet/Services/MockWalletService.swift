//
//  MockWalletService.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 24/12/22.
//

import Foundation


class MockWalletService: WalletServiceProtocol {
    let db: MockDatabase
    
//    private var wallets: [Wallet] = defaultWallets
    
    init(db: MockDatabase = MockDatabase()) {
        self.db = db
    }
    
    func getWallets() async throws -> [Wallet] {
        return db.wallets
    }
    
    func updateWallet(wallet: Wallet) async throws {
        if let index = db.wallets.firstIndex(where: { $0 == wallet }){
            db.wallets[index] = wallet
        }
    }
    
    func updateWalletAmount(id: String, amount: Double) async throws {
        if let index = db.wallets.firstIndex(where: { $0.id.uuidString == id }){
            db.wallets[index].amount += Decimal(amount)
        }
    }
    
    func createWallet(wallet: Wallet) async throws {
        db.wallets.append(wallet)
    }
    
    func deleteWallet(wallet: Wallet) async throws {
        if let index = db.wallets.firstIndex(where: { $0 == wallet }){
            db.wallets.remove(at: index)
        }
    }
}
