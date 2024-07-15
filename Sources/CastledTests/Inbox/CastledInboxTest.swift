//
//  CastledInboxTest.swift
//  CastledTests
//
//  Created by antony on 15/07/2024.
//

@testable import CastledInbox
import XCTest
@_spi(CastledInternal) import Castled
@_spi(CastledInboxTestable) import CastledInbox

final class CastledInboxTest: XCTestCase {
    override func setUpWithError() throws {
        populateMockData()
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

    func populateMockData() {
        let inboxItems = loadInboxItemsFromJSON()
        CastledCoreDataOperations.shared.refreshInboxItems(liveInboxResponse: inboxItems)
    }

    private func loadInboxItemsFromJSON() -> [CastledInboxItem] {
        guard let url = Bundle.resourceBundle(for: Self.self).url(forResource: "castled_inbox", withExtension: "json") else {
            print("JSON file not found")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            let items = try decoder.decode([CastledInboxItem].self, from: data)
            return items
        } catch {
            print("Error decoding JSON: \(error)")
            return []
        }
    }
}
