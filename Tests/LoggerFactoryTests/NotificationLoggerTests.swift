//
//  NotificationLoggerTests.swift
//
//
//  Created by kelvinwong on 2023/11/14.
//

import XCTest
@testable import LoggerFactory

final class NSNotificationLoggerTests: XCTestCase, NSUserNotificationCenterDelegate {
    
    override func setUp() async throws {
        print()
        print("==== \(self.description) ====")
        LoggerFactory.append(logWriter: ConsoleLogger())
        LoggerFactory.append(logWriter: FileLogger(pathOfFolder: "~/logs"))
        LoggerFactory.append(logWriter: FileLogger(id: "logForKeywords", pathOfFolder: "~/logs", filename: "123_for_keywords.log")
            .forKeywords(["keyword"])
        )
        LoggerFactory.enable([.info, .error, .warning, .trace])
    }
    
    
    @objc func receiver(notification:Notification){
        if let msg = (notification.object as? String) {
            print("📣 \(ISO8601DateFormatter().string(from: Date())) received notification: \(msg)")
        }
    }
    
    func testForKeywords() throws {
        NSUserNotificationCenter.default.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiver(notification:)), name: NSNotification.Name(rawValue: "GLOBAL_NOTIFICATION"), object: nil)
        
        LoggerFactory.append(logWriter: NSNotificationLogger(key: "GLOBAL_NOTIFICATION").forKeywords(["keyword"]))
        let logger = LoggerFactory.get(category: "Test", subCategory: "testForKeywords")
        logger.log("this is a log")
        logger.log("this is a keyword")
        logger.log(.trace, "this is a trace")
        logger.log(.trace, "this is another keyword")
        logger.log(.error, "this is not a keyword")
    }
    
    
    @objc(userNotificationCenter:shouldPresentNotification:) func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
}
