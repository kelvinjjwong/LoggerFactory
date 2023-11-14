//
//  FileMonitoringTimeTests.swift
//
//
//  Created by kelvinwong on 2023/11/14.
//

import XCTest
@testable import LoggerFactory

final class FileMonitoringTimeTests: XCTestCase {
    
    override func setUp() async throws {
        print()
        print("==== \(self.description) ====")
        LoggerFactory.append(logWriter: ConsoleLogger())
        LoggerFactory.enable([.info, .error, .warning, .trace])
    }
    
    func testMonitorFileTime() throws {
        LoggerFactory.append(logWriter: FileLogger(pathOfFolder: "~/logs").roll(everyHour: true, everyMinute: true))
        let logger = LoggerFactory.get(category: "Test", subCategory: "testMonitorFileTime")
        let durationExpectation = expectation(description: "durationExpectation")
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (Timer) in
            if let fileWriter = LoggerFactory.getWriter(id: "file"), let size = fileWriter.file().sizeOfFile() {
                logger.log("simulate appending log content - \(size.humanReadableValue(.useKB)) - \(size.humanReadableValue(.useBytes)) - \(size)")
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 180, execute: {
            durationExpectation.fulfill()
        })
        waitForExpectations(timeout: 180 + 1, handler: nil)
    }
}
