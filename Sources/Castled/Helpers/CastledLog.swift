//
//  Castled
//
//  Created by Antony Joe Mathew on 11/04/2023.
//

import Foundation

class CastledLog {
    private static var defaultLogLevel: CastledLogLevel = .debug
    static func setLogLevel(_ logLevel: CastledLogLevel) {
        defaultLogLevel = logLevel
    }

    static func castledLog(_ item: Any, logLevel: CastledLogLevel, separator: String = " ", terminator: String = "\n") {
        if logLevel.rawValue <= defaultLogLevel.rawValue {
            var logLvelString = "Castled"
            if logLevel == CastledLogLevel.error {
                logLvelString += " Error ❌❌❌"
            }
            print("\(logLvelString): \(item)", separator: separator, terminator: terminator)
        }
    }
}
