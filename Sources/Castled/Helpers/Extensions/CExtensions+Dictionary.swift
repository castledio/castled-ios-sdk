//
//  Dictionary+Extension.swift
//  Castled
//
//  Created by antony on 02/11/2023.
//

import Foundation

extension Dictionary where Key == String, Value: Any {
    func toJSONString() -> String? {
        do {
            if let jsonData = try? JSONSerialization.data(withJSONObject: self, options: []) {
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    return jsonString
                }
            }

        } catch {
            CastledLog.castledLog("Error converting dictionary to JSON string: \(error)", logLevel: .error)
        }
        return nil
    }

    func serializedDictionary() -> [String: Any] {
        return self.compactMapValues { value -> Any? in
            switch value {
            case let stringValue as String:
                return stringValue
            case let boolValue as Bool:
                return boolValue
            case let intValue as Int:
                return intValue
            case let doubleValue as Double:
                return doubleValue
            case let numberValue as NSNumber:
                if CFNumberIsFloatType(numberValue) {
                    return numberValue.doubleValue
                } else {
                    return numberValue.intValue
                }
            default:
                return "\(value)" // Convert other types to string
            }
        }
    }
}
