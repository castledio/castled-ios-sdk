//
//  CastledDeviceIndoUtils.swift
//  Castled
//
//  Created by antony on 10/09/2024.
//

import Foundation

class CastledDeviceInfoUtils {
    private static let lock = NSLock()

    static func getDeviceId() -> String {
        lock.lock()
        defer {
            lock.unlock()
        }
        if let deviceID = CastledUserDefaults.getString(CastledUserDefaults.kCastledDeviceIddKey) {
            return deviceID
        }
        let random = CastledCommonClass.getUniqueString()
        CastledUserDefaults.setString(CastledUserDefaults.kCastledDeviceIddKey, random)
        return random
    }
}
