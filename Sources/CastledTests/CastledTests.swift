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

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
}
