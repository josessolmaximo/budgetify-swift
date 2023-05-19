//
//  RecurringTests.swift
//  BudgetifyTests
//
//  Created by Joses Solmaximo on 30/04/23.
//

import XCTest
@testable import Budgetify

final class RecurringTests: XCTestCase {
    private var formatter: DateFormatter!
    private var recurringVM: RecurringViewModel!
    
    private var testDates = [
        Date(),
        Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
        Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
        Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
        Calendar.current.date(byAdding: .day, value: 4, to: Date())!,
        Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
        Calendar.current.date(byAdding: .day, value: 14, to: Date())!,
        Calendar.current.date(byAdding: .day, value: 21, to: Date())!,
        Calendar.current.date(byAdding: .day, value: 28, to: Date())!,
        Calendar.current.date(byAdding: .month, value: 1, to: Date())!,
        Calendar.current.date(byAdding: .month, value: 2, to: Date())!,
        Calendar.current.date(byAdding: .month, value: 3, to: Date())!,
    ]
    
    private var testTransactions: [Transaction] {
        testDates.map { date in
            Transaction(category: "", originWallet: "", destinationWallet: "", recurring: .init(type: .custom, date: date, amount: 1, customType: .last))
        }
    }
    
    @MainActor
    override func setUp() {
        formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        
        let service = MockRecurringService()
        
        service.transactions = testTransactions
        
        recurringVM = RecurringViewModel(recurringService: service)
    }
    
    override func tearDown() {
        formatter = nil
        recurringVM = nil
    }
    
    func testTransactionSorting() async throws {
        await recurringVM.getTransactions()
        
        let categorizedTransactions = await recurringVM.organizedTransactions
        
        XCTAssertEqual(categorizedTransactions.keys.count, 12)
        
        XCTAssertEqual(categorizedTransactions["Due today"]?.count, 1)
        XCTAssertEqual(categorizedTransactions["Due tomorrow"]?.count, 1)
        XCTAssertEqual(categorizedTransactions["Due in 4 days"]?.count, 1)
    }
}
