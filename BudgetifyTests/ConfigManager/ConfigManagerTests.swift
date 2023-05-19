//
//  ConfigManagerTests.swift
//  BudgetifyTests
//
//  Created by Joses Solmaximo on 28/02/23.
//

import XCTest
@testable import Budgetify

final class ConfigManagerTests: XCTestCase {
    func test_version_manager_major_less(){
        let currentVersion = "1.5.3"
        let minimumVersion = "2.1.5"
        XCTAssertEqual(currentVersion.isVersion(lessThan: minimumVersion), true)
    }
    
    func test_version_manager_major_more(){
        let currentVersion = "3.1.3"
        let minimumVersion = "2.8.5"
        XCTAssertEqual(currentVersion.isVersion(lessThan: minimumVersion), false)
    }
    
    func test_version_manager_major_equal(){
        let currentVersion = "2.6.3"
        let minimumVersion = "2.8.5"
        XCTAssertEqual(currentVersion.isVersion(lessThan: minimumVersion), true)
    }
    
    func test_version_manager_minor_less(){
        let currentVersion = "1.5.30"
        let minimumVersion = "1.7.5"
        
        XCTAssertEqual(currentVersion.isVersion(lessThan: minimumVersion), true)
    }
    
    func test_version_manager_minor_more(){
        let currentVersion = "1.7.3"
        let minimumVersion = "1.3.95"
        
        XCTAssertEqual(currentVersion.isVersion(lessThan: minimumVersion), false)
    }
    
    func test_version_manager_minor_equal(){
        let currentVersion = "1.5.3"
        let minimumVersion = "1.5.5"
        
        XCTAssertEqual(currentVersion.isVersion(lessThan: minimumVersion), true)
    }
    
    func test_version_manager_patch_less(){
        let currentVersion = "1.5.1"
        let minimumVersion = "1.5.3"
        
        XCTAssertEqual(currentVersion.isVersion(lessThan: minimumVersion), true)
    }
    
    func test_version_manager_patch_more(){
        let currentVersion = "1.5.8"
        let minimumVersion = "1.5.6"
        
        XCTAssertEqual(currentVersion.isVersion(lessThan: minimumVersion), false)
    }
    
    func test_version_manager_patch_equal(){
        let currentVersion = "1.5.5"
        let minimumVersion = "1.5.5"
        
        XCTAssertEqual(currentVersion.isVersion(lessThan: minimumVersion), false)
    }
}
