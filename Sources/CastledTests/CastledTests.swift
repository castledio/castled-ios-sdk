//
//  CastledTests.swift
//  CastledTests
//
//  Created by antony on 11/07/2024.
//

@testable import Castled
import UserNotifications
import XCTest

final class CastledTests: XCTestCase {
    var castledInitializer: CastledInitializer!
    override func setUpWithError() throws {
        castledInitializer = CastledInitializer()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        castledInitializer = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitialization() {
        castledInitializer.initializeCaslted()
        XCTAssertTrue(Castled.sharedInstance.isCastledInitialized(), "Castled SDK initialized..")
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
}
