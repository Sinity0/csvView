//
//  LineReaderTests.swift
//  cvsViewer
//
//  Created by Evgeny Mikhalkov on 06/12/2024.
//

import XCTest
@testable import cvsViewer

final class LineReaderTests: XCTestCase {
    
    private func urlForResource(_ name: String) -> URL? {
        let bundle = Bundle(for: type(of: self))
        return bundle.url(forResource: name, withExtension: "csv")
    }
    
    func testLineReaderNormalLines() {
        guard let url = urlForResource("issues_valid") else {
            XCTFail("File doesn't exist")
            return
        }
        
        guard let reader = LineReader(url: url) else {
            XCTFail("Failed to init LineReader")
            return
        }
        
        var lines = [String]()
        while let line = reader.next() {
            lines.append(line)
        }
        
        XCTAssertEqual(lines.count, 4)
    }
    
    func testLineReaderNoNewlineAtEnd() {
        guard let url = urlForResource("issues_no_new_line") else {
            XCTFail("File doesn't exists")
            return
        }
        
        guard let reader = LineReader(url: url) else {
            XCTFail("Failed to init LineReader")
            return
        }
        
        var lineCount = 0
        while let _ = reader.next() {
            lineCount += 1
        }
        
        XCTAssertEqual(lineCount, 2)
    }
    
    func testLineReaderEmptyFile() {
        guard let url = urlForResource("empty") else {
            XCTFail("File doesn't exists")
            return
        }
        guard let reader = LineReader(url: url) else {
            XCTFail("Failed to init LineReader with empty file")
            return
        }
        
        XCTAssertNil(reader.next())
    }
    
    func testLineReaderInvalidURL() {
        let invalidURL = URL(fileURLWithPath: "doesn'tExists.csv")
        let reader = LineReader(url: invalidURL)
        XCTAssertNil(reader, "LineReader should fail with invalid URL")
    }
}
