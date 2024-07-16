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
        coreDataStack = nil
        castledInitializer = nil
    }

    func testAANotInitialized() {
        XCTAssertFalse(CastledInboxTestHelper.shared.isInboxModuleInitialized(), "Castled SDK already initialized with inbox module..")
    }

    func testAClearInboxItemsBeforeOtherOperations() {
        CastledCoreDataOperations.shared.clearInboxItems()
        XCTAssertTrue(CastledCoreDataOperations.shared.getAllInboxItemsCount() == 0, "clearInboxItems() method failed..")
    }

    func testALoadItems() {
        let inboxObjects = CastledInboxMockObjects().loadInboxItemsFromJSON()
        castledInitializer.initializeCaslted(enableAppInbox: true)
        let expectation = self.expectation(description: "Populate mock data and fetch inbox items")
        CastledCoreDataOperations.shared.refreshInboxItems(liveInboxResponse: inboxObjects)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            CastledInbox.sharedInstance.getInboxItems { _, items, _ in
                XCTAssertEqual(items?.count, inboxObjects.count, "There should be \(inboxObjects.count) inbox items")
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 2.0, handler: nil)
    }

    func testGetUnreadCount() {
        let inboxObjects = CastledInboxMockObjects().loadInboxItemsFromJSON()
        castledInitializer.initializeCaslted(enableAppInbox: true)
        XCTAssertTrue(CastledInbox.sharedInstance.getInboxUnreadCount() == inboxObjects.filter { !$0.isRead }.count)
    }

    func testMarkInboxItemRead() {
        let inboxObjects = CastledInboxMockObjects().loadInboxItemsFromJSON()
        let expectation = self.expectation(description: "Mark inbox items as read")
        CastledCoreDataOperations.shared.saveInboxItemsRead(readItems: inboxObjects.filter { !$0.isRead })
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertTrue(CastledCoreDataOperations.shared.getInboxUnreadCount() == 0)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2.0, handler: nil)
    }

    func testRemoveInboxItem() {
        let inboxObjects = CastledInboxMockObjects().loadInboxItemsFromJSON()
        let expectation = self.expectation(description: "Delete last inbox item")
        castledInitializer.initializeCaslted(enableAppInbox: true)
        CastledCoreDataOperations.shared.deleteInboxItem(inboxItem: inboxObjects.last!)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            CastledInbox.sharedInstance.getInboxItems { _, items, _ in
                XCTAssertTrue(items?.count == inboxObjects.count - 1)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 2.0, handler: nil)
    }
}
