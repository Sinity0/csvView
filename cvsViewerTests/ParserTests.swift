//
//  ParserTests.swift
//  cvsViewer
//
//  Created by Evgeny Mikhalkov on 06/12/2024.
//

import XCTest
@testable import cvsViewer

final class ParserTests: XCTestCase {
    private var parser: CSVParser?
    
    override func setUp() {
        super.setUp()
        parser = CSVParser()
    }
    
    private func urlForResource(_ name: String) -> URL? {
        let bundle = Bundle(for: type(of: self))
        return bundle.url(forResource: name, withExtension: "csv")
    }
    
    func testParseCSVValidFile() {
        guard let parser = parser else {
            XCTFail("Parser is nil")
            return
        }
        
        guard let url = urlForResource("issues_valid") else {
            XCTFail("File doesn't exists")
            return
        }
        
        let exp = expectation(description: "Parsing complete")
        
        let _ = parser.parseCSV(at: url, progress: { _ in
        }, completion: { persons in
            XCTAssertEqual(persons.count, 3)
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func testParseCSVMissingFields() {
        guard let parser = parser else {
            XCTFail("Parser is nil")
            return
        }
        
        guard let url = urlForResource("issues_missing_fields") else {
            XCTFail("File doesn't exists")
            return
        }
        
        let exp = expectation(description: "Parsing complete")
        
        let _ = parser.parseCSV(at: url, progress: { _ in }, completion: { persons in
            XCTAssertEqual(persons.count, 2)
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func testParseCSVInvalidDates() {
        guard let parser = parser else {
            XCTFail("Parser is nil")
            return
        }
        
        guard let url = urlForResource("issues_invalid_dates") else {
            XCTFail("File doesn't exists")
            return
        }
        
        let exp = expectation(description: "Parsing complete")
        
        let _ = parser.parseCSV(at: url, progress: { _ in }, completion: { persons in
            XCTAssertEqual(persons.count, 2)
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func testParseCSVNoNewlineAtEnd() {
        guard let parser = parser else {
            XCTFail("Parser is nil")
            return
        }
        
        guard let url = urlForResource("issues_no_new_line") else {
            XCTFail("File doesn't exists")
            return
        }
        
        let exp = expectation(description: "Parsing complete")
        
        let _ = parser.parseCSV(at: url, progress: { _ in }, completion: { persons in
            XCTAssertEqual(persons.count, 1)
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func testParseCSVCancellation() {
        guard let parser = parser else {
            XCTFail("Parser is nil")
            return
        }
        
        guard let url = urlForResource("issues_large") else {
            XCTFail("File doesn't exists")
            return
        }
        
        let exp = expectation(description: "Parsing cancelled")
        
        let workItem = parser.parseCSV(at: url, progress: { _ in }, completion: { persons in
            XCTAssertEqual(persons.count, 0)
            exp.fulfill()
        })
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.001) {
            workItem.cancel()
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testParseCSVSmallFile() {
        guard let parser = parser else {
            XCTFail("Parser is nil")
            return
        }
        
        guard let url = urlForResource("issues_small") else {
            XCTFail("File doesn't exists")
            return
        }
        
        let exp = expectation(description: "Parsing complete")
        
        let _ = parser.parseCSV(at: url, progress: { p in
            XCTAssertGreaterThanOrEqual(p, 0.0)
            XCTAssertLessThanOrEqual(p, 1.0)
        }, completion: { persons in
            XCTAssertEqual(persons.count, 1)
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func testParserPerformance() throws {
        guard let parser = parser else {
            XCTFail("Parser is nil")
            return
        }
        
        guard let url = urlForResource("issues_large") else {
            XCTFail("File doesn't exists")
            return
        }
        
        measure {
            let expectation = self.expectation(description: "Parsing finished")
            
            let workItem = parser.parseCSV(at: url, progress: { _ in }, completion: { persons in
                XCTAssertGreaterThan(persons.count, 0, "Parsed persons should not be empty")
                expectation.fulfill()
            })
            
            wait(for: [expectation], timeout: 30.0)
            workItem.cancel()
        }
    }
}
