//
//  CastledEnvironmentChecker.swift
//  Castled
//
//  Created by antony on 12/07/2024.
//

import Foundation
import UIKit

enum CastledEnvironmentChecker {
    static func isRunningInDesignOrTestEnvironment() -> Bool {
        let processInfo = ProcessInfo.processInfo
        let processName = processInfo.processName
        let arguments = processInfo.arguments

        // Check if arguments is not empty
        guard !arguments.isEmpty else {
            return false
        }

        let infoPath = arguments[0]

        if processName == "IBDesignablesAgentCocoaTouch" ||
            processName == "IBDesignablesAgent-iOS" ||
            processName == "xctest" ||
            infoPath.contains(".appex")
        {
            return true
        } else {
            return false
        }
    }
}
