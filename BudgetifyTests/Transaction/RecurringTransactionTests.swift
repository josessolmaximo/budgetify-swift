//
//  RecurringTransactionTests.swift
//  RecurringTransactionTests
//
//  Created by Joses Solmaximo on 20/12/22.
//

import XCTest
@testable import Budgetify

final class RecurringTransactionTests: XCTestCase {
    private var formatter: DateFormatter!
    
    override func setUp() {
        formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
    }
    
    override func tearDown() {
        formatter = nil
    }
    
    func test_next_recurring_one_day(){
        let startDate = formatter.date(from: "2022/1/27 22:31")!
        let expectedDates = [
            formatter.date(from: "2022/1/28 00:00")!,
            formatter.date(from: "2022/1/29 00:00")!,
            formatter.date(from: "2022/1/30 00:00")!,
            formatter.date(from: "2022/1/31 00:00")!,
            formatter.date(from: "2022/2/01 00:00")!,
            formatter.date(from: "2022/2/02 00:00")!,
            formatter.date(from: "2022/2/03 00:00")!,
            formatter.date(from: "2022/2/04 00:00")!,
            formatter.date(from: "2022/2/05 00:00")!,
        ]
        
        let recurring = Recurring(type: .daily, date: startDate, amount: 1, customType: .first)
        
        var transaction = Transaction(category: "", date: startDate, originWallet: "", destinationWallet: "", recurring: recurring)
        
        for date in expectedDates {
            transaction = transaction.nextRecurringPeriod
            XCTAssertEqual(transaction.recurring.date, date)
        }
    }
    
    func test_next_recurring_seven_day(){
        let startDate = formatter.date(from: "2022/1/27 22:31")!
        let expectedDates = [
            formatter.date(from: "2022/2/03 00:00")!,
            formatter.date(from: "2022/2/10 00:00")!,
            formatter.date(from: "2022/2/17 00:00")!,
            formatter.date(from: "2022/2/24 00:00")!,
            formatter.date(from: "2022/3/03 00:00")!,
            formatter.date(from: "2022/3/10 00:00")!,
            formatter.date(from: "2022/3/17 00:00")!,
            formatter.date(from: "2022/3/24 00:00")!,
            formatter.date(from: "2022/3/31 00:00")!,
        ]
        
        let recurring = Recurring(type: .daily, date: startDate, amount: 7, customType: .first)
        
        var transaction = Transaction(category: "", date: startDate, originWallet: "", destinationWallet: "", recurring: recurring)
        
        for date in expectedDates {
            transaction = transaction.nextRecurringPeriod
            XCTAssertEqual(transaction.recurring.date, date)
        }
    }
    
    func test_next_recurring_one_week(){
        let startDate = formatter.date(from: "2022/1/27 22:31")!
        let expectedDates = [
            formatter.date(from: "2022/2/03 00:00")!,
            formatter.date(from: "2022/2/10 00:00")!,
            formatter.date(from: "2022/2/17 00:00")!,
            formatter.date(from: "2022/2/24 00:00")!,
            formatter.date(from: "2022/3/03 00:00")!,
            formatter.date(from: "2022/3/10 00:00")!,
            formatter.date(from: "2022/3/17 00:00")!,
            formatter.date(from: "2022/3/24 00:00")!,
            formatter.date(from: "2022/3/31 00:00")!,
        ]
        
        let recurring = Recurring(type: .weekly, date: startDate, amount: 1, customType: .first)
        
        var transaction = Transaction(category: "", date: startDate, originWallet: "", destinationWallet: "", recurring: recurring)
        
        for date in expectedDates {
            transaction = transaction.nextRecurringPeriod
            XCTAssertEqual(transaction.recurring.date, date)
        }
    }
    
    func test_next_recurring_two_week(){
        let startDate = formatter.date(from: "2022/1/27 22:31")!
        let expectedDates = [
            formatter.date(from: "2022/2/10 00:00")!,
            formatter.date(from: "2022/2/24 00:00")!,
            formatter.date(from: "2022/3/10 00:00")!,
            formatter.date(from: "2022/3/24 00:00")!,
            formatter.date(from: "2022/4/07 00:00")!,
            formatter.date(from: "2022/4/21 00:00")!,
            formatter.date(from: "2022/5/05 00:00")!,
            formatter.date(from: "2022/5/19 00:00")!,
            formatter.date(from: "2022/6/02 00:00")!,
        ]
        
        let recurring = Recurring(type: .weekly, date: startDate, amount: 2, customType: .first)
        
        var transaction = Transaction(category: "", date: startDate, originWallet: "", destinationWallet: "", recurring: recurring)
        
        for date in expectedDates {
            transaction = transaction.nextRecurringPeriod
            XCTAssertEqual(transaction.recurring.date, date)
        }
    }
    
    func test_next_recurring_one_month(){
        let startDate = formatter.date(from: "2022/8/27 22:31")!
        let expectedDates = [
            formatter.date(from: "2022/9/27 00:00")!,
            formatter.date(from: "2022/10/27 00:00")!,
            formatter.date(from: "2022/11/27 00:00")!,
            formatter.date(from: "2022/12/27 00:00")!,
            formatter.date(from: "2023/1/27 00:00")!,
            formatter.date(from: "2023/2/27 00:00")!,
            formatter.date(from: "2023/3/27 00:00")!,
            formatter.date(from: "2023/4/27 00:00")!,
            formatter.date(from: "2023/5/27 00:00")!,
        ]
        
        let recurring = Recurring(type: .monthly, date: startDate, amount: 1, customType: .first)
        
        var transaction = Transaction(category: "", date: startDate, originWallet: "", destinationWallet: "", recurring: recurring)
        
        for date in expectedDates {
            transaction = transaction.nextRecurringPeriod
            XCTAssertEqual(transaction.recurring.date, date)
        }
    }
    
    func test_next_recurring_two_month(){
        let startDate = formatter.date(from: "2022/8/27 22:31")!
        let expectedDates = [
            formatter.date(from: "2022/10/27 00:00")!,
            formatter.date(from: "2022/12/27 00:00")!,
            formatter.date(from: "2023/2/27 00:00")!,
            formatter.date(from: "2023/4/27 00:00")!,
            formatter.date(from: "2023/6/27 00:00")!,
            formatter.date(from: "2023/8/27 00:00")!,
            formatter.date(from: "2023/10/27 00:00")!,
            formatter.date(from: "2023/12/27 00:00")!,
            formatter.date(from: "2024/2/27 00:00")!,
        ]
        
        let recurring = Recurring(type: .monthly, date: startDate, amount: 2, customType: .first)
        
        var transaction = Transaction(category: "", date: startDate, originWallet: "", destinationWallet: "", recurring: recurring)
        
        for date in expectedDates {
            transaction = transaction.nextRecurringPeriod
            XCTAssertEqual(transaction.recurring.date, date)
        }
    }
    
    func test_next_recurring_weekdays_STWS(){
        let startDate = formatter.date(from: "2022/1/27 22:31")!
        let expectedDates = [
            formatter.date(from: "2022/1/29 00:00")!,
            formatter.date(from: "2022/1/30 00:00")!,
            formatter.date(from: "2022/2/01 00:00")!,
            formatter.date(from: "2022/2/02 00:00")!,
            formatter.date(from: "2022/2/05 00:00")!,
            formatter.date(from: "2022/2/06 00:00")!,
            formatter.date(from: "2022/2/08 00:00")!,
            formatter.date(from: "2022/2/09 00:00")!,
            formatter.date(from: "2022/2/12 00:00")!,
        ]
        
        let recurring = Recurring(type: .days, date: startDate, amount: 1, customType: .first, weekdays: ["Sunday", "Tuesday", "Wednesday", "Saturday"])
        
        var transaction = Transaction(category: "", date: startDate, originWallet: "", destinationWallet: "", recurring: recurring)
        
        for date in expectedDates {
            transaction = transaction.nextRecurringPeriod
            XCTAssertEqual(transaction.recurring.date, date)
        }
    }
    
    func test_next_recurring_weekdays_SMTWTFS(){
        let startDate = formatter.date(from: "2022/1/27 22:31")!
        let expectedDates = [
            formatter.date(from: "2022/1/28 00:00")!,
            formatter.date(from: "2022/1/29 00:00")!,
            formatter.date(from: "2022/1/30 00:00")!,
            formatter.date(from: "2022/1/31 00:00")!,
            formatter.date(from: "2022/2/01 00:00")!,
            formatter.date(from: "2022/2/02 00:00")!,
            formatter.date(from: "2022/2/03 00:00")!,
            formatter.date(from: "2022/2/04 00:00")!,
            formatter.date(from: "2022/2/05 00:00")!,
        ]
        
        let recurring = Recurring(type: .days, date: startDate, amount: 1, customType: .first, weekdays: ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"])
        
        var transaction = Transaction(category: "", date: startDate, originWallet: "", destinationWallet: "", recurring: recurring)
        
        for date in expectedDates {
            transaction = transaction.nextRecurringPeriod
            XCTAssertEqual(transaction.recurring.date, date)
        }
    }
    
    func test_next_recurring_weekdays_MWS(){
        let startDate = formatter.date(from: "2022/1/27 22:31")!
        let expectedDates = [
            formatter.date(from: "2022/1/29 00:00")!,
            formatter.date(from: "2022/1/31 00:00")!,
            formatter.date(from: "2022/2/02 00:00")!,
            formatter.date(from: "2022/2/05 00:00")!,
            formatter.date(from: "2022/2/07 00:00")!,
            formatter.date(from: "2022/2/09 00:00")!,
            formatter.date(from: "2022/2/12 00:00")!,
            formatter.date(from: "2022/2/14 00:00")!,
            formatter.date(from: "2022/2/16 00:00")!,
        ]
        
        let recurring = Recurring(type: .days, date: startDate, amount: 1, customType: .first, weekdays: ["Monday", "Wednesday", "Saturday"])
        
        var transaction = Transaction(category: "", date: startDate, originWallet: "", destinationWallet: "", recurring: recurring)
        
        for date in expectedDates {
            transaction = transaction.nextRecurringPeriod
            XCTAssertEqual(transaction.recurring.date, date)
        }
    }
    
    func test_next_recurring_custom_start_1(){
        let startDate = formatter.date(from: "2022/1/27 22:31")!
        let expectedDates = [
            formatter.date(from: "2022/2/01 00:00")!,
            formatter.date(from: "2022/3/01 00:00")!,
            formatter.date(from: "2022/4/01 00:00")!,
            formatter.date(from: "2022/5/01 00:00")!,
            formatter.date(from: "2022/6/01 00:00")!,
            formatter.date(from: "2022/7/01 00:00")!,
            formatter.date(from: "2022/8/01 00:00")!,
            formatter.date(from: "2022/9/01 00:00")!,
            formatter.date(from: "2022/10/01 00:00")!,
        ]
        
        let recurring = Recurring(type: .custom, date: startDate, amount: 1, customType: .first)
        
        var transaction = Transaction(category: "", date: startDate, originWallet: "", destinationWallet: "", recurring: recurring)
        
        for date in expectedDates {
            transaction = transaction.nextRecurringPeriod
            XCTAssertEqual(transaction.recurring.date, date)
        }
    }
    
    func test_next_recurring_custom_start_28(){
        let startDate = formatter.date(from: "2022/1/27 22:31")!
        let expectedDates = [
            formatter.date(from: "2022/1/28 00:00")!,
            formatter.date(from: "2022/2/28 00:00")!,
            formatter.date(from: "2022/3/28 00:00")!,
            formatter.date(from: "2022/4/28 00:00")!,
            formatter.date(from: "2022/5/28 00:00")!,
            formatter.date(from: "2022/6/28 00:00")!,
            formatter.date(from: "2022/7/28 00:00")!,
            formatter.date(from: "2022/8/28 00:00")!,
            formatter.date(from: "2022/9/28 00:00")!,
        ]
        
        let recurring = Recurring(type: .custom, date: startDate, amount: 28, customType: .first)
        
        var transaction = Transaction(category: "", date: startDate, originWallet: "", destinationWallet: "", recurring: recurring)
        
        for date in expectedDates {
            transaction = transaction.nextRecurringPeriod
            XCTAssertEqual(transaction.recurring.date, date)
        }
    }
    
    func test_next_recurring_custom_end_1(){
        let startDate = formatter.date(from: "2022/1/27 22:31")!
        let expectedDates = [
            formatter.date(from: "2022/1/31 00:00")!,
            formatter.date(from: "2022/2/28 00:00")!,
            formatter.date(from: "2022/3/31 00:00")!,
            formatter.date(from: "2022/4/30 00:00")!,
            formatter.date(from: "2022/5/31 00:00")!,
            formatter.date(from: "2022/6/30 00:00")!,
            formatter.date(from: "2022/7/31 00:00")!,
            formatter.date(from: "2022/8/31 00:00")!,
            formatter.date(from: "2022/9/30 00:00")!,
        ]
        
        let recurring = Recurring(type: .custom, date: startDate, amount: 1, customType: .last)
        
        var transaction = Transaction(category: "", date: startDate, originWallet: "", destinationWallet: "", recurring: recurring)
        
        for date in expectedDates {
            transaction = transaction.nextRecurringPeriod
            XCTAssertEqual(transaction.recurring.date, date)
        }
    }
    
    func test_next_recurring_custom_end_28(){
        let startDate = formatter.date(from: "2022/1/27 22:31")!
        let expectedDates = [
            formatter.date(from: "2022/2/01 00:00")!,
            formatter.date(from: "2022/3/04 00:00")!,
            formatter.date(from: "2022/4/03 00:00")!,
            formatter.date(from: "2022/5/04 00:00")!,
            formatter.date(from: "2022/6/03 00:00")!,
            formatter.date(from: "2022/7/04 00:00")!,
            formatter.date(from: "2022/8/04 00:00")!,
            formatter.date(from: "2022/9/03 00:00")!,
            formatter.date(from: "2022/10/04 00:00")!,
        ]
        
        let recurring = Recurring(type: .custom, date: startDate, amount: 28, customType: .last)
        
        var transaction = Transaction(category: "", date: startDate, originWallet: "", destinationWallet: "", recurring: recurring)
        
        for date in expectedDates {
            transaction = transaction.nextRecurringPeriod
            XCTAssertEqual(transaction.recurring.date, date)
        }
    }
}
