import XCTest
@testable import LoggerFactory

final class LoggerFactoryTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(LoggerFactory().text, "Hello, World!")
    }
}
