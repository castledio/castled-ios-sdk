//
//  CastledTests.swift
//  CastledTests
//
//  Created by antony on 11/07/2024.
//

@testable import Castled
import UserNotifications
import XCTest

final class CastledTests: XCTestCase, CastledNotificationDelegate {
    // 4
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        print("setUp")
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        print("setUpWithError")
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        print("tearDownWithError")
    }

    func testInitialization() {
        let config = CastledConfigs.initialize(appId: "718c38e2e359d94367a2e0d35e1fd4df")
        config.enableAppInbox = true
        config.enablePush = false
        config.enableInApp = true
        config.enableTracking = true
        config.enableSessionTracking = true
        config.skipUrlHandling = false
        config.sessionTimeOutSec = 15
        config.location = CastledLocation.US
        config.logLevel = CastledLogLevel.debug
        config.appGroupId = "group.com.castled.CastledPushDemo.Castled"
        Castled.initialize(withConfig: config, andDelegate: self)
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
