//
//  CastledNotificationServiceManager.swift
//  CastledNotificationService
//
//  Created by antony on 05/09/2024.
//

import Foundation
@_spi(CastledInternal) import Castled

enum CastledNotificationServiceLogManager {
    static func logMessage(_ message: String, logLevel: CastledLogLevel) {
        CastledLog.castledLog(message, logLevel: logLevel)
    }
}
