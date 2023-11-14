//
//  FileMonitoringTimeAndSizeTests.swift
//
//
//  Created by kelvinwong on 2023/11/14.
//

import XCTest
@testable import LoggerFactory

final class FileMonitoringTimeAndSizeTests: XCTestCase {
    
    override func setUp() async throws {
        print()
        print("==== \(self.description) ====")
        LoggerFactory.append(logWriter: ConsoleLogger())
        LoggerFactory.enable([.info, .error, .warning, .trace])
    }
    
    func testMonitorFileTimeAndSize() throws {
        LoggerFactory.append(logWriter: FileLogger(pathOfFolder: "~/logs").roll(atSize: 10, unit: .useKB, everyHour: true, everyMinute: true))
        let logger = LoggerFactory.get(category: "Test", subCategory: "testMonitorFileTime")
        let durationExpectation = expectation(description: "durationExpectation")
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (Timer) in
            if let fileWriter = LoggerFactory.getWriter(id: "file"), let size = fileWriter.file().sizeOfFile() {
                logger.log("""
The earliest known appearance of the phrase was in The Boston Journal. In an article titled "Current Notes" in the February 9, 1885, edition, the phrase is mentioned as a good practice sentence for writing students: "A favorite copy set by writing teachers for their pupils is the following, because it contains every letter of the alphabet: 'A quick brown fox jumps over the lazy dog.'"[1] Dozens of other newspapers published the phrase over the next few months, all using the version of the sentence starting with "A" rather than "The".[2] The earliest known use of the phrase starting with "The" is from the 1888 book Illustrative Shorthand by Linda Bronson.[3] The modern form (starting with "The") became more common even though it is slightly longer than the original (starting with "A").

A 1908 edition of the Los Angeles Herald Sunday Magazine records that when the New York Herald was equipping an office with typewriters "a few years ago", staff found that the common practice sentence of "now is the time for all good men to come to the aid of the party" did not familiarize typists with the entire alphabet, and ran onto two lines in a newspaper column. They write that a staff member named Arthur F. Curtis invented the "quick brown fox" pangram to address this.[4]


Pictorial depiction of the pangram from Scouting for Boys (1908)[5]
As the use of typewriters grew in the late 19th century, the phrase began appearing in typing lesson books as a practice sentence. Early examples include How to Become Expert in Typewriting: A Complete Instructor Designed Especially for the Remington Typewriter (1890),[6] and Typewriting Instructor and Stenographer's Hand-book (1892). By the turn of the 20th century, the phrase had become widely known. In the January 10, 1903, issue of Pitman's Phonetic Journal, it is referred to as "the well known memorized typing line embracing all the letters of the alphabet".[7] Robert Baden-Powell's book Scouting for Boys (1908) uses the phrase as a practice sentence for signaling.[5]

The first message sent on the Moscow–Washington hotline on August 30, 1963, was the test phrase "THE QUICK BROWN FOX JUMPED OVER THE LAZY DOG'S BACK 1234567890".[8] Later, during testing, the Russian translators sent a message asking their American counterparts, "What does it mean when your people say 'The quick brown fox jumped over the lazy dog'?"[9]

During the 20th century, technicians tested typewriters and teleprinters by typing the sentence.[10]

It is the sentence used in the annual Zaner-Bloser National Handwriting Competition, a cursive writing competition which has been held in the U.S. since 1991.[11][12]
""")
                logger.log("simulate appending log content - \(size.humanReadableValue(.useKB)) - \(size.humanReadableValue(.useBytes)) - \(size)")
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 180, execute: {
            durationExpectation.fulfill()
        })
        waitForExpectations(timeout: 180 + 1, handler: nil)
    }
}
