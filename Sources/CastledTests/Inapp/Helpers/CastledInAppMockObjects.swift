//
//  CastledInAppMockObjects.swift
//  CastledTests
//
//  Created by antony on 16/07/2024.
//

import Foundation
import UIKit
@_spi(CastledInternal) import Castled

class CastledInAppMockObjects: NSObject {
    func loadInAppItems() -> [CastledInAppObject] {
        guard let url = Bundle.resourceBundle(for: Self.self).url(forResource: "castled_inapp", withExtension: "json") else {
            print("JSON file not found")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            let items = try decoder.decode([CastledInAppObject].self, from: data)
            return items
        } catch {
            print("Error decoding JSON: \(error)")
            return []
        }
    }
}
