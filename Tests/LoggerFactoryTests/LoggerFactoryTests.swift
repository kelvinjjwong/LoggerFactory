import XCTest
@testable import LoggerFactory

final class LoggerFactoryTests: XCTestCase {
    
    override func setUp() async throws {
        print()
        print("==== \(self.description) ====")
        LoggerFactory.removeAll()
        LoggerFactory.append(logWriter: ConsoleLogger())
        LoggerFactory.append(logWriter: FileLogger(pathOfFolder: "~/logs"))
        LoggerFactory.append(logWriter: FileLogger(id: "logForCategoryTest123", pathOfFolder: "~/logs", filename: "123_for_category_Test123.log"), coverAll: false)
//        LoggerFactory.append(id: "logForSubCategory", logWriter: FileLogger(pathOfFolder: "~/logs", filename: "123_for_subcategory.log"))
//        LoggerFactory.append(id: "logForKeywords", logWriter: FileLogger(pathOfFolder: "~/logs", filename: "123_for_keywords.log"))
        LoggerFactory.enable([.info, .error, .warning, .trace]) // trace is allowed in global level
        LoggerFactory.enable(category: "Test123", types: [.info, .error, .warning, .debug], writers: ["logForCategoryTest123"]) // debug is not allowed in global level, but not allow trace
        LoggerFactory.enable(category: "Special", types: [.info, .error, .warning, .debug]) // debug is not allowed in global level, but not allow trace
        LoggerFactory.enable(category: "Particular", subCategory: "ABC", types: [.info, .error, .warning, .debug]) // debug is not allowed in global level, but not allow trace
    }
    
    func testMultipleLoggers() throws {
        
        let logger = LoggerFactory.get(category: "Test", subCategory: "testMultipleLoggers")
        logger.printWriters()
        logger.log("this is a log")
        logger.log(.info, "this is a info")
        logger.log(.error, "this is an error")
        logger.log(.warning, "this is a warning")
        logger.log(.debug, "this is a debug")
        logger.log(.trace, "this is a trace")
    }
    
    func testLimitedTypes() throws {
        
        let logger = LoggerFactory.get(category: "Test", subCategory: "testLimitedTypes")
        logger.printWriters()
        logger.log("this is a log")
        logger.log(.info, "this is a info")
        logger.log(.error, "this is an error")
        logger.log(.warning, "this is a warning")
        logger.log(.debug, "this is a debug")
        logger.log(.trace, "this is a trace")
    }
    
    func testForCategory() throws {
        
        let logger = LoggerFactory.get(category: "Test123", subCategory: "testForCategory")
        logger.printWriters()
        logger.log("this is a log")
        logger.log(.info, "this is a info")
        logger.log(.error, "this is an error")
        logger.log(.warning, "this is a warning")
        logger.log(.debug, "this is a debug")
        logger.log(.trace, "this is a trace")
        
        
        let special = LoggerFactory.get(category: "Special", subCategory: "testForCategory")
        logger.printWriters()
        special.log("this is a log")
        special.log(.info, "this is a info")
        special.log(.error, "this is an error")
        special.log(.warning, "this is a warning")
        special.log(.debug, "this is a debug")
        special.log(.trace, "this is a trace")
    }
    
    func testForSubCategory() throws {
        
        let logger = LoggerFactory.get(category: "Test123", subCategory: "testForSubCategory", separated: true)
        logger.printWriters()
        logger.log("this is a log")
        logger.log(.info, "this is a info")
        logger.log(.error, "this is an error")
        logger.log(.warning, "this is a warning")
        logger.log(.debug, "this is a debug")
        logger.log(.trace, "this is a trace")
        
        
        let special = LoggerFactory.get(category: "Particular", subCategory: "ABC")
        logger.printWriters()
        special.log("this is a log")
        special.log(.info, "this is a info")
        special.log(.error, "this is an error")
        special.log(.warning, "this is a warning")
        special.log(.debug, "this is a debug")
        special.log(.trace, "this is a trace")
    }
    
    func testForKeywords() throws {
        
        let logger = LoggerFactory.get(category: "Test", subCategory: "testForKeywords")
        logger.printWriters()
        logger.log("this is a log")
        logger.log("this is a keyword")
        logger.log(.info, "this is a info")
        logger.log(.error, "this is an error")
        logger.log(.warning, "this is a warning")
        logger.log(.debug, "this is a debug")
        logger.log(.trace, "this is a trace")
        logger.log(.trace, "this trace another keyword")
    }
}
