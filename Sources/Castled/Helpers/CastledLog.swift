//
//  Castled
//
//  Created by Antony Joe Mathew on 11/04/2023.
//

import Foundation
@_spi(CastledInternal)
import os.log

public enum CastledLog {
    private static var defaultLogLevel: CastledLogLevel = .debug
    private static let logger = OSLog(subsystem: "com.castled.logging", category: "Castled")

    static func setLogLevel(_ logLevel: CastledLogLevel) {
        defaultLogLevel = logLevel
    }

    public static func castledLog(_ item: Any, logLevel: CastledLogLevel, separator: String = " ", terminator: String = "\n") {
        if logLevel.rawValue <= defaultLogLevel.rawValue {
            var logLevelString = "Castled"
            var logType = OSLogType.debug

            switch logLevel {
            case .error:
                logLevelString += " Error ❌"
                logType = OSLogType.error
            case .warning:
                logLevelString += " Warning ⚠️"
                logType = OSLogType.error
            case .info:
                // logLevelString += " Info ℹ️"
                logType = OSLogType.info
            case .debug:
                // logLevelString += " Debug"
                logType = OSLogType.debug
            case .none:
                break
            }

            let message = "\(logLevelString): \(item)"
            os_log("%{public}@", log: logger, type: logType, message)
        }
    }
}
