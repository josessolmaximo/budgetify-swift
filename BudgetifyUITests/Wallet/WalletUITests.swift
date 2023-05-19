//
//  BudgetifyUITests.swift
//  BudgetifyUITests
//
//  Created by Joses Solmaximo on 24/12/22.
//

import XCTest

final class WalletUITests: XCTestCase {
    private var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["ui-testing"]
        app.launchEnvironment = ["ispremium": "1"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }
    
    func test_wallet_exists() throws {
        XCTAssertTrue(app.buttons["creditcard.fill"].exists)
        
        app.buttons["creditcard.fill"].tap()
        
        for wallet in defaultWallets {
            let elementsQuery = app.scrollViews
            
            XCTAssertTrue(elementsQuery.staticTexts[wallet.name].waitForExistence(timeout: 5))
            XCTAssertTrue(elementsQuery.images[wallet.image].exists)
            XCTAssertTrue(elementsQuery.staticTexts[wallet.amount.toString].exists)
        }
    }
    
    func test_create_wallet() throws {
        let walletButton = app.buttons["creditcard.fill"]
        
        XCTAssertTrue(walletButton.exists)
        
        walletButton.tap()
        
        XCTAssertTrue(app.staticTexts["Wallets"].exists)
        XCTAssertTrue(app.staticTexts["Net Worth"].waitForExistence(timeout: 2))
        
        let createButton = app.buttons["createButton"]
        
        XCTAssertTrue(createButton.exists)
        
        createButton.tap()
        
        XCTAssertTrue(app.staticTexts["Exclude from Net Worth"].exists)
        
        XCTAssertTrue(app.navigationBars.buttons["createButton"].exists)
        XCTAssertTrue(app.navigationBars.buttons["cancelButton"].exists)
        
        XCTAssertTrue(app.buttons["iconPicker"].exists)
        
        XCTAssertTrue(app.buttons["Debit"].exists)
        XCTAssertTrue(app.buttons["Credit"].exists)
        XCTAssertTrue(app.buttons["Target"].exists)
        
        XCTAssertTrue(app.buttons["square"].exists)
        XCTAssertTrue(app.buttons["custom.wallet"].exists)
        
        XCTAssertTrue(app.textFields["nameTextfield"].exists)
        XCTAssertTrue(app.textFields["amountTextfield"].exists)
        
//        sleep(3)
        
        app.navigationBars.buttons["createButton"].tap()
        
        XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: 5))
        
        if let errorDescription = WalletValidation.invalidName.errorDescription {
            XCTAssertTrue(app.alerts.firstMatch.staticTexts[errorDescription].exists)
        }
        
        if let recoverySuggestion = WalletValidation.invalidName.recoverySuggestion {
            XCTAssertTrue(app.alerts.firstMatch.staticTexts[recoverySuggestion].exists)
        }
        
        app.alerts.firstMatch.buttons.firstMatch.tap()
        
        XCTAssertFalse(app.alerts.firstMatch.exists)
        
        app.buttons["iconPicker"].tap()
        
        app.buttons["Logos"].tap()
        
        app.scrollViews.otherElements.buttons["logo.bca"].tap()
        
        XCTAssertTrue(app.buttons["logo.bca"].waitForExistence(timeout: 5))
        
        app.textFields["nameTextfield"].tap()
        app.textFields["nameTextfield"].typeText("BCA")
        
        app.textFields["amountTextfield"].tap()
        app.textFields["amountTextfield"].typeText("43200")
        
        app.navigationBars.buttons["createButton"].tap()
        
        sleep(3)
        
        XCTAssertFalse(app.textFields["nameTextfield"].exists)
        
        XCTAssertTrue(app.scrollViews.staticTexts["BCA"].exists)
        XCTAssertTrue(app.scrollViews.images["logo.bca"].exists)
        XCTAssertTrue(app.scrollViews.staticTexts[Decimal(43200).toString].exists)
    }
}
