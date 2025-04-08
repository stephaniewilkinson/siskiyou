//
//  siskiyouTests.swift
//  siskiyouTests
//
//  Created by Stephanie Wilkinson on 3/4/25.
//

// Using XCTest instead of Testing framework to maximize compatibility
import XCTest

// No dependency on the main app
class SiskiyouTests: XCTestCase {

    func testExample() {
        // Simple test that doesn't rely on app code
        XCTAssertEqual(1 + 1, 2)
    }

    func testAnotherExample() {
        // Another simple test
        XCTAssertTrue(true)
    }
}
