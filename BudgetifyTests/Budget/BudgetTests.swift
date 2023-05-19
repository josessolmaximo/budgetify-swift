//
//  BudgetTests.swift
//  BudgetifyTests
//
//  Created by Joses Solmaximo on 06/02/23.
//

import XCTest
@testable import Budgetify

final class BudgetTests: XCTestCase {
    private var formatter: DateFormatter!
    private var budget: Budget!
    
    override func setUp() {
        formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        budget = Budget(budgetAmount: 100, carryover: true, carryoverAmount: 0)
    }
    
    override func tearDown() {
        formatter = nil
    }
    
    func test_next_recurring_one_day(){
        let startDate = formatter.date(from: "2022/1/27 22:31:00")!
        let expectedDates = [
            formatter.date(from: "2022/1/28 23:59:59")!,
            formatter.date(from: "2022/1/29 23:59:59")!,
            formatter.date(from: "2022/1/30 23:59:59")!,
            formatter.date(from: "2022/1/31 23:59:59")!,
            formatter.date(from: "2022/2/01 23:59:59")!,
            formatter.date(from: "2022/2/02 23:59:59")!,
            formatter.date(from: "2022/2/03 23:59:59")!,
            formatter.date(from: "2022/2/04 23:59:59")!,
            formatter.date(from: "2022/2/05 23:59:59")!,
        ]
        
        let period = BudgetPeriod(type: .daily, amount: 1, customType: .first)
        
        budget.startDate = startDate
        budget.endDate = startDate
        budget.createdAt = startDate
        
        budget.period = period
        
        for (index, date) in expectedDates.enumerated() {
            budget = budget.nextPeriod
            XCTAssertEqual(budget.endDate, date)
            XCTAssertEqual(budget.carryoverAmount, Decimal(index * 100))
        }
    }
    
    func test_next_recurring_seven_day(){
        let startDate = formatter.date(from: "2022/1/27 22:31:00")!
        let expectedDates = [
            formatter.date(from: "2022/2/03 23:59:59")!,
            formatter.date(from: "2022/2/10 23:59:59")!,
            formatter.date(from: "2022/2/17 23:59:59")!,
            formatter.date(from: "2022/2/24 23:59:59")!,
            formatter.date(from: "2022/3/03 23:59:59")!,
            formatter.date(from: "2022/3/10 23:59:59")!,
            formatter.date(from: "2022/3/17 23:59:59")!,
            formatter.date(from: "2022/3/24 23:59:59")!,
            formatter.date(from: "2022/3/31 23:59:59")!,
        ]
        
        let period = BudgetPeriod(type: .daily, amount: 7, customType: .first)
        
        budget.startDate = startDate
        budget.endDate = startDate
        budget.createdAt = startDate
        
        budget.period = period
        
        for (index, date) in expectedDates.enumerated() {
            budget = budget.nextPeriod
            XCTAssertEqual(budget.endDate, date)
            XCTAssertEqual(budget.carryoverAmount, Decimal(index * 100))
        }
    }
    
    func test_next_recurring_one_week(){
        let startDate = formatter.date(from: "2022/1/27 22:31:00")!
        let expectedDates = [
            formatter.date(from: "2022/2/03 23:59:59")!,
            formatter.date(from: "2022/2/10 23:59:59")!,
            formatter.date(from: "2022/2/17 23:59:59")!,
            formatter.date(from: "2022/2/24 23:59:59")!,
            formatter.date(from: "2022/3/03 23:59:59")!,
            formatter.date(from: "2022/3/10 23:59:59")!,
            formatter.date(from: "2022/3/17 23:59:59")!,
            formatter.date(from: "2022/3/24 23:59:59")!,
            formatter.date(from: "2022/3/31 23:59:59")!,
        ]
        
        let period = BudgetPeriod(type: .weekly, amount: 1, customType: .first)
        
        budget.startDate = startDate
        budget.endDate = startDate
        budget.createdAt = startDate
        
        budget.period = period
        
        for (index, date) in expectedDates.enumerated() {
            budget = budget.nextPeriod
            XCTAssertEqual(budget.endDate, date)
            XCTAssertEqual(budget.carryoverAmount, Decimal(index * 100))
        }
    }
    
    func test_next_recurring_two_week(){
        let startDate = formatter.date(from: "2022/1/27 22:31:00")!
        let expectedDates = [
            formatter.date(from: "2022/2/10 23:59:59")!,
            formatter.date(from: "2022/2/24 23:59:59")!,
            formatter.date(from: "2022/3/10 23:59:59")!,
            formatter.date(from: "2022/3/24 23:59:59")!,
            formatter.date(from: "2022/4/07 23:59:59")!,
            formatter.date(from: "2022/4/21 23:59:59")!,
            formatter.date(from: "2022/5/05 23:59:59")!,
            formatter.date(from: "2022/5/19 23:59:59")!,
            formatter.date(from: "2022/6/02 23:59:59")!,
        ]
        
        let period = BudgetPeriod(type: .weekly, amount: 2, customType: .first)
        
        budget.startDate = startDate
        budget.endDate = startDate
        budget.createdAt = startDate
        
        budget.period = period
        
        for (index, date) in expectedDates.enumerated() {
            budget = budget.nextPeriod
            XCTAssertEqual(budget.endDate, date)
            XCTAssertEqual(budget.carryoverAmount, Decimal(index * 100))
        }
    }
    
    func test_next_recurring_custom_start_1(){
        let startDate = formatter.date(from: "2022/1/27 22:31:00")!
        let expectedDates = [
            formatter.date(from: "2022/2/01 23:59:59")!,
            formatter.date(from: "2022/3/01 23:59:59")!,
            formatter.date(from: "2022/4/01 23:59:59")!,
            formatter.date(from: "2022/5/01 23:59:59")!,
            formatter.date(from: "2022/6/01 23:59:59")!,
            formatter.date(from: "2022/7/01 23:59:59")!,
            formatter.date(from: "2022/8/01 23:59:59")!,
            formatter.date(from: "2022/9/01 23:59:59")!,
            formatter.date(from: "2022/10/01 23:59:59")!,
        ]
        
        let period = BudgetPeriod(type: .monthly, amount: 1, customType: .first)
        
        budget.startDate = startDate
        budget.endDate = startDate
        budget.createdAt = startDate
        
        budget.period = period
        
        for (index, date) in expectedDates.enumerated() {
            budget = budget.nextPeriod
            XCTAssertEqual(budget.endDate, date)
            XCTAssertEqual(budget.carryoverAmount, Decimal(index * 100))
        }
    }
    
    func test_next_recurring_custom_start_28(){
        let startDate = formatter.date(from: "2022/1/27 22:31:00")!
        let expectedDates = [
            formatter.date(from: "2022/1/28 23:59:59")!,
            formatter.date(from: "2022/2/28 23:59:59")!,
            formatter.date(from: "2022/3/28 23:59:59")!,
            formatter.date(from: "2022/4/28 23:59:59")!,
            formatter.date(from: "2022/5/28 23:59:59")!,
            formatter.date(from: "2022/6/28 23:59:59")!,
            formatter.date(from: "2022/7/28 23:59:59")!,
            formatter.date(from: "2022/8/28 23:59:59")!,
            formatter.date(from: "2022/9/28 23:59:59")!,
        ]
        
        let period = BudgetPeriod(type: .monthly, amount: 28, customType: .first)
        
        budget.startDate = startDate
        budget.endDate = startDate
        budget.createdAt = startDate
        
        budget.period = period
        
        for (index, date) in expectedDates.enumerated() {
            budget = budget.nextPeriod
            XCTAssertEqual(budget.endDate, date)
            XCTAssertEqual(budget.carryoverAmount, Decimal(index * 100))
        }
    }
    
    func test_next_recurring_custom_end_1(){
        let startDate = formatter.date(from: "2022/1/28 00:00:00")!
        let endDate = formatter.date(from: "2022/1/31 23:59:59")!
        let expectedDates = [
            formatter.date(from: "2022/2/28 23:59:59")!,
            formatter.date(from: "2022/3/31 23:59:59")!,
            formatter.date(from: "2022/4/30 23:59:59")!,
            formatter.date(from: "2022/5/31 23:59:59")!,
            formatter.date(from: "2022/6/30 23:59:59")!,
            formatter.date(from: "2022/7/31 23:59:59")!,
            formatter.date(from: "2022/8/31 23:59:59")!,
            formatter.date(from: "2022/9/30 23:59:59")!,
        ]
        
        let period = BudgetPeriod(type: .monthly, amount: 1, customType: .last)
        
        budget.startDate = startDate
        budget.endDate = endDate
        budget.createdAt = startDate
        
        budget.period = period
        
        for (index, date) in expectedDates.enumerated() {
            budget = budget.nextPeriod
            XCTAssertEqual(budget.endDate, date)
            XCTAssertEqual(budget.carryoverAmount, Decimal((index + 1) * 100))
        }
    }
    
    func test_next_recurring_custom_end_28(){
        let startDate = formatter.date(from: "2022/1/27 22:31:00")!
        let expectedDates = [
            formatter.date(from: "2022/2/01 23:59:59")!,
            formatter.date(from: "2022/3/04 23:59:59")!,
            formatter.date(from: "2022/4/03 23:59:59")!,
            formatter.date(from: "2022/5/04 23:59:59")!,
            formatter.date(from: "2022/6/03 23:59:59")!,
            formatter.date(from: "2022/7/04 23:59:59")!,
            formatter.date(from: "2022/8/04 23:59:59")!,
            formatter.date(from: "2022/9/03 23:59:59")!,
            formatter.date(from: "2022/10/04 23:59:59")!,
        ]
        
        let period = BudgetPeriod(type: .monthly, amount: 28, customType: .last)
        
        budget.startDate = startDate
        budget.endDate = startDate
        budget.createdAt = startDate
        
        budget.period = period
        
        for (index, date) in expectedDates.enumerated() {
            budget = budget.nextPeriod
            XCTAssertEqual(budget.endDate, date)
            XCTAssertEqual(budget.carryoverAmount, Decimal(index * 100))
        }
    }
}
