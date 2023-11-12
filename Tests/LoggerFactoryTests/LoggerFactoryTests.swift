import XCTest
@testable import LoggerFactory

final class LoggerFactoryTests: XCTestCase {
    
    
    override func setUp() async throws {
        print()
        print("==== \(self.description) ====")
        LoggerFactory.append(logWriter: ConsoleLogger())
        LoggerFactory.append(logWriter: FileLogger(pathOfFolder: "~/logs"))
        LoggerFactory.enable([.info, .error, .warning, .trace])
    }
    
    func testMultipleLoggers() throws {
        
        let logger = LoggerFactory.get(category: "Test", subCategory: "testMultipleLoggers")
            .registerWriter(id: "otherfile", writer: FileLogger(pathOfFolder: "~/logs", filename: "123.log"))
        logger.log("this is a log")
        logger.log(.trace, "this is a trace")
    }
    
    func testLimitedTypes() throws {
        
        let logger = LoggerFactory.get(category: "Test", subCategory: "testLimitedTypes")
            .registerWriter(id: "otherfile", writer: FileLogger(pathOfFolder: "~/logs", filename: "123.log"))
            .excludeLoggingLevels([.trace])
        logger.log("this is a log")
        logger.log(.trace, "this is a trace")
    }
}
