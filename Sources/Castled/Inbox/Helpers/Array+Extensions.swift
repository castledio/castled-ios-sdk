//
//  Array+Extensions.swift
//  Castled
//
//  Created by antony on 02/11/2023.
//
import Foundation

extension Array where Element == [String: Any] {
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
                dictionariesAreEqual(dict1: element, dict2: otherElement)
            }
        }
    }

    func dictionariesAreEqual(dict1: [String: Any], dict2: [String: Any]) -> Bool {
        // Implement your custom comparison logic here
        // Example: Check if dictionaries have the same keys and values
        return NSDictionary(dictionary: dict1).isEqual(to: dict2)
    }
}
