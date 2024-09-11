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

    static func dataFromArrayOrDictionary<T>(_ item: T) -> Data? where T: Any {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: item, options: [])
            return jsonData
        } catch {
            return nil
        }
    }

    // Function to encode an Encodable object to Data
    static func dataFromEncodable<T: Encodable>(_ object: T) -> Data? {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            return data
        } catch {
            print("Error encoding object: \(error.localizedDescription)")
            return nil
        }
    }

    func encodableFromData<T: Decodable>(to type: T.Type) -> T? {
        let decoder = JSONDecoder()
        do {
            let decodedObject = try decoder.decode(T.self, from: self)
            return decodedObject
        } catch {
            print("Error decoding data: \(error.localizedDescription)")
            return nil
        }
    }
}
