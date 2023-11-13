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
        LoggerFactory.append(logWriter: FileLogger(pathOfFolder: "~/logs"))
        LoggerFactory.enable([.info, .error, .warning, .trace])
        
    }
    
    func testMonitorFileSize() throws {
        let logger = LoggerFactory.get(category: "Test", subCategory: "testMonitorFileSize")
        let durationExpectation = expectation(description: "durationExpectation")
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (Timer) in
            if let fileWriter = LoggerFactory.getWriter(id: "file"), let size = fileWriter.path().sizeOfFile() {
                let bcf = ByteCountFormatter()
                bcf.allowedUnits = [.useBytes]
                bcf.countStyle = .file
                let string = bcf.string(fromByteCount: size)
                logger.log("\(string) - \(size)")
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: {
            durationExpectation.fulfill()
        })
        waitForExpectations(timeout: 10 + 1, handler: nil)
    }
}
