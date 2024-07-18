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
    static let APP_OPENED_ID = 1254
    static let CUSTOM_INAPP_ID = 1257

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAANotInitialized() {
        preloadInApps()
        Castled.sharedInstance.logCustomAppEvent("added_to_cart", params: [:])
        Castled.sharedInstance.logAppOpenedEventIfAny()
        Castled.sharedInstance.logPageViewedEvent("DetailsScreen")
        XCTAssertTrue(CastledTestingHelper.shared.getSatisifiedInApps().isEmpty)
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

    func testZInvalidCustomEventInApp() {
        CastledInitializer().initializeCaslted(enableInApp: true)
        preloadInApps()
        Castled.sharedInstance.logCustomAppEvent("invalid_inapps", params: [:])
        let expectation = XCTestExpectation(description: "Checking for custom inapps")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertEqual(CastledTestingHelper.shared.getSatisifiedInApps().filter {
                ![CastledInAppTests.CUSTOM_INAPP_ID, CastledInAppTests.APP_OPENED_ID, CastledInAppTests.PAGE_VIEWED_ID].contains($0.notificationID)
            }.count, 0)
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
