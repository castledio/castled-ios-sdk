//
//  CastledInboxMockObjects.swift
//  CastledTests
//
//  Created by antony on 15/07/2024.
//

import UIKit
@_spi(CastledInternal) import Castled
@_spi(CastledInboxTestable) import CastledInbox

class CastledInboxMockObjects: NSObject {
    func loadInboxItemsFromJSON() -> [CastledInboxItem] {
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
