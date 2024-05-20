//
//  DecodingContainer+Extensions.swift
//  Castled
//
//  Created by antony on 30/08/2023.
//
// https://stackoverflow.com/questions/44603248/how-to-decode-a-property-with-type-of-json-dictionary-in-swift-45-decodable-pr
import Foundation
@_spi(CastledInternal)

public class JSONCodingKeys: CodingKey {
    public var stringValue: String

    public required init?(stringValue: String) {
        self.stringValue = stringValue
    }

    public var intValue: Int?

    public required convenience init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
        self.intValue = intValue
    }
}

public extension KeyedDecodingContainer {
    func decode(_ type: [String: Any].Type, forKey key: K) throws -> [String: Any] {
        let container = try nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
        return try container.decode(type)
    }

    func decodeIfPresent(_ type: [String: Any].Type, forKey key: K) throws -> [String: Any]? {
        guard contains(key) else {
            return nil
        }
        guard try decodeNil(forKey: key) == false else {
            return nil
        }
        return try self.decode(type, forKey: key)
    }

    func decode(_ type: [Any].Type, forKey key: K) throws -> [Any] {
        var container = try nestedUnkeyedContainer(forKey: key)
        return try container.decode(type)
    }

    func decodeIfPresent(_ type: [Any].Type, forKey key: K) throws -> [Any]? {
        guard contains(key) else {
            return nil
        }
        guard try decodeNil(forKey: key) == false else {
            return nil
        }
        return try self.decode(type, forKey: key)
    }

    func decode(_ type: [String: Any].Type) throws -> [String: Any] {
        var dictionary = [String: Any]()

        for key in allKeys {
            if let boolValue = try? decode(Bool.self, forKey: key) {
                dictionary[key.stringValue] = boolValue
            } else if let stringValue = try? decode(String.self, forKey: key) {
                dictionary[key.stringValue] = stringValue
            } else if let intValue = try? decode(Int.self, forKey: key) {
                dictionary[key.stringValue] = intValue
            } else if let doubleValue = try? decode(Double.self, forKey: key) {
                dictionary[key.stringValue] = doubleValue
            } else if let nestedDictionary = try? decode([String: Any].self, forKey: key) {
                dictionary[key.stringValue] = nestedDictionary
            } else if let nestedArray = try? decode([Any].self, forKey: key) {
                dictionary[key.stringValue] = nestedArray
            }
        }
        return dictionary
    }
}

extension UnkeyedDecodingContainer {
    mutating func decode(_ type: [Any].Type) throws -> [Any] {
        var array: [Any] = []
        while isAtEnd == false {
            // See if the current value in the JSON array is `null` first and prevent infite recursion with nested arrays.
            if try decodeNil() {
                continue
            } else if let value = try? decode(Bool.self) {
                array.append(value)
            } else if let value = try? decode(Double.self) {
                array.append(value)
            } else if let value = try? decode(String.self) {
                array.append(value)
            } else if let nestedDictionary = try? decode([String: Any].self) {
                array.append(nestedDictionary)
            } else if let nestedArray = try? decode([Any].self) {
                array.append(nestedArray)
            }
        }
        return array
    }

    mutating func decode(_ type: [String: Any].Type) throws -> [String: Any] {
        let nestedContainer = try self.nestedContainer(keyedBy: JSONCodingKeys.self)
        return try nestedContainer.decode(type)
    }
}

// https://satyenmaurya95.medium.com/string-any-support-for-codable-4ba062ce62f2

// MARK: - Encoding Extensions

extension KeyedEncodingContainer {
    mutating func encodeIfPresent(_ value: [String: Any]?, forKey key: KeyedEncodingContainer<K>.Key) throws {
        guard let safeValue = value, !safeValue.isEmpty else {
            return
        }
        var container = self.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
        for item in safeValue {
            if let val = item.value as? Int {
                try container.encodeIfPresent(val, forKey: JSONCodingKeys(stringValue: item.key)!)
            } else if let val = item.value as? String {
                try container.encodeIfPresent(val, forKey: JSONCodingKeys(stringValue: item.key)!)
            } else if let val = item.value as? Double {
                try container.encodeIfPresent(val, forKey: JSONCodingKeys(stringValue: item.key)!)
            } else if let val = item.value as? Float {
                try container.encodeIfPresent(val, forKey: JSONCodingKeys(stringValue: item.key)!)
            } else if let val = item.value as? Bool {
                try container.encodeIfPresent(val, forKey: JSONCodingKeys(stringValue: item.key)!)
            } else if let val = item.value as? [Any] {
                try container.encodeIfPresent(val, forKey: JSONCodingKeys(stringValue: item.key)!)
            } else if let val = item.value as? [String: Any] {
                try container.encodeIfPresent(val, forKey: JSONCodingKeys(stringValue: item.key)!)
            }
        }
    }

    mutating func encodeIfPresent(_ value: [Any]?, forKey key: KeyedEncodingContainer<K>.Key) throws {
        guard let safeValue = value else {
            return
        }
        if let val = safeValue as? [Int] {
            try self.encodeIfPresent(val, forKey: key)
        } else if let val = safeValue as? [String] {
            try self.encodeIfPresent(val, forKey: key)
        } else if let val = safeValue as? [Double] {
            try self.encodeIfPresent(val, forKey: key)
        } else if let val = safeValue as? [Float] {
            try self.encodeIfPresent(val, forKey: key)
        } else if let val = safeValue as? [Bool] {
            try self.encodeIfPresent(val, forKey: key)
        } else if let val = value as? [[String: Any]] {
            var container = self.nestedUnkeyedContainer(forKey: key)
            try container.encode(contentsOf: val)
        }
    }
}

extension UnkeyedEncodingContainer {
    mutating func encode(contentsOf sequence: [[String: Any]]) throws {
        for dict in sequence {
            try self.encodeIfPresent(dict)
        }
    }

    mutating func encodeIfPresent(_ value: [String: Any]) throws {
        var container = self.nestedContainer(keyedBy: JSONCodingKeys.self)
        for item in value {
            if let val = item.value as? Int {
                try container.encodeIfPresent(val, forKey: JSONCodingKeys(stringValue: item.key)!)
            } else if let val = item.value as? String {
                try container.encodeIfPresent(val, forKey: JSONCodingKeys(stringValue: item.key)!)
            } else if let val = item.value as? Double {
                try container.encodeIfPresent(val, forKey: JSONCodingKeys(stringValue: item.key)!)
            } else if let val = item.value as? Float {
                try container.encodeIfPresent(val, forKey: JSONCodingKeys(stringValue: item.key)!)
            } else if let val = item.value as? Bool {
                try container.encodeIfPresent(val, forKey: JSONCodingKeys(stringValue: item.key)!)
            } else if let val = item.value as? [Any] {
                try container.encodeIfPresent(val, forKey: JSONCodingKeys(stringValue: item.key)!)
            } else if let val = item.value as? [String: Any] {
                try container.encodeIfPresent(val, forKey: JSONCodingKeys(stringValue: item.key)!)
            }
        }
    }
}

/*
 @objcMembers
 public class AnyCodable: NSObject, Codable {
 @objc public var value: Any

 @objc public init(_ value: Any) {
 self.value = value
 super.init()
 }

 public required init(from decoder: Decoder) throws {
 let container = try decoder.singleValueContainer()
 if container.decodeNil() {
 self.value = NSNull()
 } else if let intValue = try? container.decode(Int.self) {
 self.value = NSNumber(value: intValue)
 } else if let doubleValue = try? container.decode(Double.self) {
 self.value = NSNumber(value: doubleValue)
 } else if let stringValue = try? container.decode(String.self) {
 self.value = stringValue
 } else if let boolValue = try? container.decode(Bool.self) {
 self.value = NSNumber(value: boolValue)
 } else if let arrayValue = try? container.decode([AnyCodable].self) {
 self.value = arrayValue.map { $0.value }
 } else if let dictionaryValue = try? container.decode([String: AnyCodable].self) {
 self.value = dictionaryValue.mapValues { $0.value }
 } else {
 throw DecodingError.dataCorrupted(
 DecodingError.Context(
 codingPath: decoder.codingPath,
 debugDescription: "Unsupported type"
 )
 )
 }
 super.init()
 }

 public func encode(to encoder: Encoder) throws {
 var container = encoder.singleValueContainer()
 switch value {
 case is NSNull:
 try container.encodeNil()
 case let intValue as NSNumber:
 try container.encode(intValue.intValue)
 case let doubleValue as NSNumber:
 try container.encode(doubleValue.doubleValue)
 case let stringValue as String:
 try container.encode(stringValue)
 case let boolValue as NSNumber:
 try container.encode(boolValue.boolValue)
 case let arrayValue as [Any]:
 let anyCodableArray = arrayValue.map(AnyCodable.init)
 try container.encode(anyCodableArray)
 case let dictionaryValue as [String: Any]:
 let anyCodableDictionary = dictionaryValue.mapValues(AnyCodable.init)
 try container.encode(anyCodableDictionary)
 default:
 throw EncodingError.invalidValue(
 value,
 EncodingError.Context(
 codingPath: encoder.codingPath,
 debugDescription: "Unsupported type"
 )
 )
 }
 }
 }

 */
