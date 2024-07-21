//
//  CastledSessionsTest.swift
//  CastledTests
//
//  Created by antony on 17/07/2024.
//

@testable import Castled
import XCTest
@_spi(CastledInternal) import Castled
@_spi(CastledTestable) import Castled

final class CastledSessionsTest: XCTestCase {
    static var lastSessionId: String?
    let sessionTestDuration = 2.0

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStartSession() {
        CastledInitializer().initializeCaslted(enableSessionTracking: true, sessionDuration: Int(sessionTestDuration))
        let expectationStartSession = XCTestExpectation(description: "Start session")
        let expectationEndSession = XCTestExpectation(description: "End session")
        NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // create session is in anothere thread, so need a short delay to get the session id
            CastledSessionsTest.lastSessionId = CastledTestingHelper.shared.getSessionId()
            XCTAssertNotNil(CastledSessionsTest.lastSessionId)
            XCTAssertTrue(!CastledSessionsTest.lastSessionId!.isEmpty)
            expectationStartSession.fulfill()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                // adding 1 sec duration for current session
                NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
                expectationEndSession.fulfill()
            }
        }
        wait(for: [expectationStartSession, expectationEndSession], timeout: sessionTestDuration + 1)
    }

    func testVerifySessionChangeStatus() {
        CastledInitializer().initializeCaslted(enableSessionTracking: true, sessionDuration: Int(sessionTestDuration))
        let expectationFGSession = XCTestExpectation(description: "Check session")
        let expectationNewSession = XCTestExpectation(description: "New session")
        DispatchQueue.main.asyncAfter(deadline: .now() + sessionTestDuration + 1) {
            NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)
            expectationFGSession.fulfill()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                // create session is in anothere thread, so need a short delay to get the session id
                XCTAssertNotEqual(CastledSessionsTest.lastSessionId, CastledTestingHelper.shared.getSessionId(), "SessionIds should be different")
                let lastSessionDuration = CastledTestingHelper.shared.getLastSessionDuration()
//                XCTAssertNotEqual(lastSessionDuration, 0, "Last session duration cannot be zero")
//                XCTAssertLessThan(lastSessionDuration, 86400) // 1day
                expectationNewSession.fulfill()
            }
        }
        wait(for: [expectationFGSession, expectationNewSession], timeout: sessionTestDuration + 2)
    }
}
