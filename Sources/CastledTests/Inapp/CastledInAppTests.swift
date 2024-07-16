//
//  CastledInAppTests.swift
//  CastledTests
//
//  Created by antony on 16/07/2024.
//

@testable import Castled
@_spi(CastledInternal) import Castled
@_spi(CastledTestable) import Castled
import XCTest

final class CastledInAppTests: XCTestCase {
    static let PAGE_VIEWED_ID = 1256
    static let APP_OPENED_ID = 1255
    static let CUSTOM_INAPP_ID = 1257

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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

    func testAppOpenedInApp() {
        CastledInitializer().initializeCaslted(enableInApp: true)
        preloadInApps()
        Castled.sharedInstance.logAppOpenedEventIfAny()
        let expectation = XCTestExpectation(description: "Checking for App opened inapps")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertGreaterThan(CastledTestingHelper.shared.getSatisifiedInApps().filter { $0.notificationID == CastledInAppTests.APP_OPENED_ID }.count, 0)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func testLogPageViewedEvent() {
        CastledInitializer().initializeCaslted(enableInApp: true)
        preloadInApps()
        Castled.sharedInstance.logPageViewedEvent("DetailsScreen")
        let expectation = XCTestExpectation(description: "Checking for page viewed inapps")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertGreaterThan(CastledTestingHelper.shared.getSatisifiedInApps().filter { $0.notificationID == CastledInAppTests.PAGE_VIEWED_ID }.count, 0)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func testCustomEventInApp() {
        CastledInitializer().initializeCaslted(enableInApp: true)
        preloadInApps()
        Castled.sharedInstance.logCustomAppEvent("added_to_cart", params: [:])
        let expectation = XCTestExpectation(description: "Checking for custom inapps")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertGreaterThan(CastledTestingHelper.shared.getSatisifiedInApps().filter { $0.notificationID == CastledInAppTests.CUSTOM_INAPP_ID }.count, 0)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    private func preloadInApps() {
        let inapps = CastledInAppMockObjects().loadInAppItems()
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(inapps) {
            CastledUserDefaults.setObjectFor(CastledUserDefaults.kCastledInAppsList, data)
        }
    }
}
