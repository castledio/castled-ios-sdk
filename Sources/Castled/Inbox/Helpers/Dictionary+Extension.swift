//
//  Dictionary+Extension.swift
//  Castled
//
//  Created by antony on 02/11/2023.
//

import UIKit

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
}
