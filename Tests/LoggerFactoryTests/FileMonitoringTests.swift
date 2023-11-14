//
//  File.swift
//  
//
//  Created by Kelvin Wong on 2023/11/14.
//

import XCTest
@testable import LoggerFactory

final class FileMonitoringTests: XCTestCase {
    
    override func setUp() async throws {
        print()
        print("==== \(self.description) ====")
        LoggerFactory.append(logWriter: ConsoleLogger())
        LoggerFactory.enable([.info, .error, .warning, .trace])
    }
    
    func testMonitorFileSize() throws {
        LoggerFactory.append(logWriter: FileLogger(pathOfFolder: "~/logs").roll(atSize: 2, unit: .useKB))
        let logger = LoggerFactory.get(category: "Test", subCategory: "testMonitorFileSize")
        let durationExpectation = expectation(description: "durationExpectation")
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (Timer) in
            if let fileWriter = LoggerFactory.getWriter(id: "file"), let size = fileWriter.file().sizeOfFile() {
                logger.log("simulate appending log content - \(size.humanReadableValue(.useKB)) - \(size.humanReadableValue(.useBytes)) - \(size)")
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 60, execute: {
            durationExpectation.fulfill()
        })
        waitForExpectations(timeout: 60 + 1, handler: nil)
    }
}
