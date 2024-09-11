//
//  CastledInboxTest.swift
//  CastledTests
//
//  Created by antony on 15/07/2024.
//

@testable import Castled
@testable import CastledInbox
import XCTest
@_spi(CastledInboxTestable) import CastledInbox

final class CastledInboxTest: XCTestCase {
    var coreDataStack: CastledTestCoreDataStack!
    var castledInitializer: CastledInitializer!

    override func setUpWithError() throws {
        coreDataStack = CastledTestCoreDataStack()
        castledInitializer = CastledInitializer()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        castledInitializer.initializeCaslted()// this for reseting the
        coreDataStack = nil
        castledInitializer = nil
    }

    func testAANotInitialized() {
        CastledInbox.sharedInstance.getInboxItems(completion: { success, _, _ in
            XCTAssertFalse(success)
        })

        XCTAssertTrue(CastledInbox.sharedInstance.getInboxUnreadCount() == 0)

        let expectation = XCTestExpectation(description: "Listen for unread count")
        var isFulFilled = false
        CastledInbox.sharedInstance.observeUnreadCountChanges { unreadCount in
            if !isFulFilled {
                // adding this conditon to prevent the call back after other db actions
                isFulFilled = true
                XCTAssertTrue(unreadCount == 0)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1.0)

        XCTAssertFalse(CastledInboxTestHelper.shared.isInboxModuleInitialized(), "Castled SDK already initialized with inbox module..")
    }

    func testAClearInboxItemsBeforeOtherOperations() {
        CastledInboxCoreDataOperations.shared.clearInboxItems()
        XCTAssertTrue(CastledInboxCoreDataOperations.shared.getAllInboxItemsCount() == 0, "clearInboxItems() method failed..")
    }

    func testALoadItems() {
        let inboxObjects = CastledInboxMockObjects().loadInboxItemsFromJSON()
        castledInitializer.initializeCaslted(enableAppInbox: true)
        let expectation = XCTestExpectation(description: "Populate mock data and fetch inbox items")
        CastledInboxCoreDataOperations.shared.refreshInboxItems(liveInboxResponse: inboxObjects)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            CastledInbox.sharedInstance.getInboxItems { _, items, _ in
                XCTAssertEqual(items?.count, inboxObjects.count, "There should be \(inboxObjects.count) inbox items")
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func testGetUnreadCount() {
        let inboxObjects = CastledInboxMockObjects().loadInboxItemsFromJSON()
        castledInitializer.initializeCaslted(enableAppInbox: true)
        XCTAssertTrue(CastledInbox.sharedInstance.getInboxUnreadCount() == inboxObjects.filter { !$0.isRead }.count)
    }

    func testListenerForUnreadCount() {
        let expectation = XCTestExpectation(description: "Listen for unread count")
        let inboxObjects = CastledInboxMockObjects().loadInboxItemsFromJSON()
        var isFulFilled = false
        castledInitializer.initializeCaslted(enableAppInbox: true)
        CastledInbox.sharedInstance.observeUnreadCountChanges { unreadCount in
            if !isFulFilled {
                // adding this conditon to prevent the call back after other db actions
                isFulFilled = true
                XCTAssertTrue(inboxObjects.filter { !$0.isRead }.count == unreadCount)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testMarkInboxItemRead() {
        let inboxObjects = CastledInboxMockObjects().loadInboxItemsFromJSON()
        let expectation = XCTestExpectation(description: "Mark inbox items as read")
        CastledInboxCoreDataOperations.shared.saveInboxItemsRead(readItems: inboxObjects.filter { !$0.isRead })
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertTrue(CastledInboxCoreDataOperations.shared.getInboxUnreadCount() == 0)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func testRemoveInboxItem() {
        let inboxObjects = CastledInboxMockObjects().loadInboxItemsFromJSON()
        let expectation = XCTestExpectation(description: "Delete last inbox item")
        castledInitializer.initializeCaslted(enableAppInbox: true)
        CastledInboxCoreDataOperations.shared.deleteInboxItem(inboxItem: inboxObjects.last!)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            CastledInbox.sharedInstance.getInboxItems { _, items, _ in
                XCTAssertTrue(items?.count == inboxObjects.count - 1)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 2.0)
    }
}
