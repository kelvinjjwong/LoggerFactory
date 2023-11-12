import XCTest
@testable import LoggerFactory

final class LoggerFactoryTests: XCTestCase {
    
    
    override func setUp() async throws {
        print()
        print("==== \(self.description) ====")
        LoggerFactory.append(logWriter: ConsoleLogger())
        LoggerFactory.append(logWriter: FileLogger(pathOfFolder: "~/logs"))
    }
    
    func testMultipleLoggers() throws {
        
        let logger = LoggerFactory.get(category: "Test", subCategory: "UnitTest")
            .registerWriter(id: "otherfile", writer: FileLogger(pathOfFolder: "~/logs", filename: "123.log"))
        logger.log("this is a log")
    }
}
