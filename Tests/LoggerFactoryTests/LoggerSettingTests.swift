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
    
    func testLoadSettings() async throws {
        
        LoggerFactory2.default.registerConsoleLogger()
        LoggerFactory2.default.registerFileLogger(id: "test1", folder: "~/logs", filename: "logger-setting-test1")
        
        let logger = LoggerFactory2.default.get(category: "TestA", subCategory: "AA__BB__CC")
        
        await logger.log(.info, "this is an info")
        await logger.log(.warning, "this is a warning")
        await logger.log(.error, "this is an error")
        await logger.log(.debug, "this is for debug only")
        await logger.log(.trace, "this is for trace only")
        
        let logger2 = LoggerFactory2.default.get(category: "TestA", subCategory: "DD++EE++FF")
        
        await logger2.log(.info, "this is an info")
        await logger2.log(.warning, "this is a warning")
        await logger2.log(.error, "this is an error")
        await logger2.log(.debug, "this is for debug only")
        await logger2.log(.trace, "this is for trace only")
        
        
        
    }
}
