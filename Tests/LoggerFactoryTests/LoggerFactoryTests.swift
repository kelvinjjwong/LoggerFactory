import XCTest
@testable import LoggerFactory

final class LoggerFactoryTests: XCTestCase {
    
    override func setUp() async throws {
        print()
        print("==== \(self.description) ====")
        LoggerFactory.append(logWriter: ConsoleLogger())
        LoggerFactory.append(logWriter: FileLogger(pathOfFolder: "~/logs"))
        LoggerFactory.append(id: "logForCategory", logWriter: FileLogger(pathOfFolder: "~/logs", filename: "123_for_category.log")
            .forCategories(["Test123"]))
        LoggerFactory.append(id: "logForSubCategory", logWriter: FileLogger(pathOfFolder: "~/logs", filename: "123_for_subcategory.log")
            .forCategories(["Test123"])
            .forSubCategories(["testForSubCategory"])
        )
        LoggerFactory.append(id: "logForKeywords", logWriter: FileLogger(pathOfFolder: "~/logs", filename: "123_for_keywords.log")
            .forKeywords(["keyword"])
        )
        LoggerFactory.enable([.info, .error, .warning, .trace])
    }
    
    func testMultipleLoggers() throws {
        
        let logger = LoggerFactory.get(category: "Test", subCategory: "testMultipleLoggers")
        logger.log("this is a log")
        logger.log(.trace, "this is a trace")
    }
    
    func testLimitedTypes() throws {
        
        let logger = LoggerFactory.get(category: "Test", subCategory: "testLimitedTypes")
        logger.log("this is a log")
        logger.log(.trace, "this is a trace")
    }
    
    func testForCategory() throws {
        
        let logger = LoggerFactory.get(category: "Test123", subCategory: "testForCategory")
        logger.log("this is a log")
        logger.log(.trace, "this is a trace")
    }
    
    func testForSubCategory() throws {
        
        let logger = LoggerFactory.get(category: "Test123", subCategory: "testForSubCategory")
        logger.log("this is a log")
        logger.log(.trace, "this is a trace")
    }
    
    func testForKeywords() throws {
        
        let logger = LoggerFactory.get(category: "Test", subCategory: "testForKeywords")
        logger.log("this is a log")
        logger.log("this is a keyword")
        logger.log(.trace, "this is a trace")
        logger.log(.trace, "this is another keyword")
        logger.log(.error, "this is not a keyword")
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
