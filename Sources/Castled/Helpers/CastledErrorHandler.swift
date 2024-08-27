//
//  CastledErrorHandler.swift
//  Castled
//
//  Created by antony on 27/08/2024.
//

import Foundation

enum CastledErrorHandler {
    static func throwCastledFatalError(errorMessage: String) {
        CastledLog.castledLog(errorMessage, logLevel: .error)
        // Trigger a fatal error in debug mode
        #if DEBUG
            fatalError(errorMessage)
        #endif
    }
}
