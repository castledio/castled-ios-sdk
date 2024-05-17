//
//  Data+Extensions.swift
//  Castled
//
//  Created by antony on 03/10/2023.
//

import Foundation
@_spi(CastledInternal)

public extension Data {
    func objectFromCastledData<T>() -> T? where T: Any {
        do {
            let decodedData = try JSONSerialization.jsonObject(with: self, options: []) as? T
            return decodedData
        } catch {
            return nil
        }
    }

    static func dataFromObject<T>(_ item: T) -> Data? where T: Any {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: item, options: [])
            return jsonData
        } catch {
            return nil
        }
    }
}
