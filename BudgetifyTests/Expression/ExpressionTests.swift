//
//  ExpressionTests.swift
//  BudgetifyTests
//
//  Created by Joses Solmaximo on 14/07/23.
//

import XCTest
import Expression
import Budgetify

final class ExpressionTests: XCTestCase {
    var numberFormatter: NumberFormatter!
    
    override func setUpWithError() throws {
        let nf = NumberFormatter()
        
        nf.numberStyle = .decimal
        
        nf.minimumFractionDigits = 0
        nf.maximumFractionDigits = 10
        
        numberFormatter = nf
    }
    
    override func tearDownWithError() throws {
        numberFormatter = nil
    }
    
    func testExpression() {
        var expressionText = "1\(numberFormatter.groupingSeparator!)000*2\(numberFormatter.decimalSeparator!)0555"
        
        print("XCTESTDEBUG", numberFormatter.locale.identifier, numberFormatter.groupingSeparator, numberFormatter.decimalSeparator)
        
        expressionText = expressionText
            .replacingOccurrences(of: numberFormatter.groupingSeparator!, with: "")
            .replacingOccurrences(of: numberFormatter.decimalSeparator!, with: ".")
        
        let expression = Expression(expressionText)
        
        let expressionAmount = try? expression.evaluate()
        
        XCTAssertEqual(2055.5, expressionAmount)
        
        let expressionString = numberFormatter.string(from: expressionAmount! as NSNumber)
        let resultString = numberFormatter.string(from: 2055.5 as NSNumber)
        
        XCTAssertEqual(resultString, expressionString, numberFormatter.locale.identifier)
    }
    
    func test_us(){
        numberFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        testExpression()
    }
    
    func test_id(){
        numberFormatter.locale = Locale(identifier: "id")
        
        testExpression()
    }
    
    func test_gb(){
        numberFormatter.locale = Locale(identifier: "en_GB")
        
        testExpression()
    }
    
    func test_fi(){
        numberFormatter.locale = Locale(identifier: "fi_FI")
        
        testExpression()
    }
    
    func test_my(){
        numberFormatter.locale = Locale(identifier: "ms_MY")
        
        testExpression()
    }
    
    func test_ca(){
        numberFormatter.locale = Locale(identifier: "en_CA")
        
        testExpression()
    }
    
    func test_ph(){
        numberFormatter.locale = Locale(identifier: "fil_PH")
        
        testExpression()
    }
    
    func test_ar_EG(){
        numberFormatter.locale = Locale(identifier: "ar_EG")
        
        testExpression()
    }
}
