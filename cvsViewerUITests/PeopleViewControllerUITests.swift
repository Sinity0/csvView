//
//  PeopleViewControllerUITests.swift
//  cvsViewer
//
//  Created by Evgeny Mikhalkov on 07/12/2024.
//

import XCTest

final class PeopleViewControllerUITests: XCTestCase {
    var app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launch()
    }
    
    func testEmptyStateAppears() {
        let emptyView = app.otherElements["emptyStateView"]
        let emptyLabel = app.staticTexts["emptyStateLabel"]
        
        XCTAssertTrue(emptyView.waitForExistence(timeout: 5), "Empty state view should appear if no content.")
        XCTAssertTrue(emptyLabel.exists, "Empty state label should be visible.")
        XCTAssertEqual(emptyLabel.label, "Choose .csv document to visualize")
    }
    
    func testOpenFilePickerButtonExists() {
        let navBar = app.navigationBars[".csv Visualizer"]
        let openFileButton = navBar.buttons["openFilePickerButton"]
        XCTAssertTrue(openFileButton.exists, "The open file picker button should be visible.")
    }
    
    func testTapFilePickerButton() {
        let navBar = app.navigationBars[".csv Visualizer"]
        let openFileButton = navBar.buttons["openFilePickerButton"]
        openFileButton.tap()
    }
}
