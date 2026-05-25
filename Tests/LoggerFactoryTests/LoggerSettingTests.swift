//
//  LoggerSettingTests.swift
//  LoggerFactory
//
//  Created by Kelvin Wong on 2026/5/24.
//

import XCTest
@testable import LoggerFactory

final class LoggerSettingTests: XCTestCase {
    
    override func setUp() async throws {
        print()
        print("==== \(self.description) ====")
        
    }
    
    func testLoadSettings() throws {
        
        LoggerFactory2.default.registerConsoleLogger()
        LoggerFactory2.default.registerFileLogger(id: "test1", folder: "~/logs", filename: "logger-setting-test1")
        
        let logger = LoggerFactory2.default.get(category: "Test", subCategory: "testSetting")
        
        logger.log(.info, "this is an info")
        logger.log(.warning, "this is a warning")
        logger.log(.error, "this is an error")
        logger.log(.debug, "this is for debug only")
        logger.log(.trace, "this is for trace only")
        
        let logger2 = LoggerFactory2.default.get(category: "Test", subCategory: "testSetting2")
        
        logger2.log(.info, "this is an info")
        logger2.log(.warning, "this is a warning")
        logger2.log(.error, "this is an error")
        logger2.log(.debug, "this is for debug only")
        logger2.log(.trace, "this is for trace only")
        
        let json = LoggerSetting2.default.getSettingsAsJson()
        
        
        
    }
}
