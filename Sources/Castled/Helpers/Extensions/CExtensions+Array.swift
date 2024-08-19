//
//  Array+Extensions.swift
//  Castled
//
//  Created by antony on 02/11/2023.
//
import Foundation
@_spi(CastledInternal)

public extension Array where Element == [String: Any] {
    func removeDuplicates() -> [[String: Any]] {
        var uniqueArray: [[String: Any]] = []
        for dictionary in self {
            if !uniqueArray.contains(where: { element in
                dictionariesAreEqual(dict1: element, dict2: dictionary)
            }) {
                uniqueArray.append(dictionary)
            }
        }

        return uniqueArray
    }

    func subtract(_ otherArray: [[String: Any]]) -> [[String: Any]] {
        return filter { element in
            !otherArray.contains { otherElement in
                self.dictionariesAreEqual(dict1: element, dict2: otherElement)
            }
        }
    }

    func dictionariesAreEqual(dict1: [String: Any], dict2: [String: Any]) -> Bool {
        // Implement your custom comparison logic here
        // Example: Check if dictionaries have the same keys and values
        return NSDictionary(dictionary: dict1).isEqual(to: dict2)
    }

    func decode<T: Codable>(_ type: T.Type) -> [T] {
        do {
            // Convert array of dictionaries to JSON data
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: [])

            // Decode JSON data to array of Codable objects
            let decoder = JSONDecoder()
            let decodedObjects = try decoder.decode([T].self, from: jsonData)
            return decodedObjects
        } catch {
            // Log the error if needed
            print("Error decoding data: \(error)")
            // Return an empty array in case of error
            return []
        }
    }
}

extension Array where Element: Equatable {
    mutating func mergeElements<C: Collection>(newElements: C) where C.Iterator.Element == Element {
        let filteredList = newElements.filter({ !self.contains($0) })
        self.append(contentsOf: filteredList)
    }
}
