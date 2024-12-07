//
//  PersonTests.swift
//  cvsViewer
//
//  Created by Evgeny Mikhalkov on 06/12/2024.
//

import XCTest
@testable import cvsViewer

final class PersonTests: XCTestCase {
    func testPersonInitialization() {
        let date = Date(timeIntervalSince1970: 0)
        let person = Person(firstName: "Theo", surName: "Jansen", issueCount: 10, dateOfBirth: date)
        
        XCTAssertEqual(person.firstName, "Theo")
        XCTAssertEqual(person.surName, "Jansen")
        XCTAssertEqual(person.issueCount, 10)
        XCTAssertEqual(person.dateOfBirth, date)
    }
}
