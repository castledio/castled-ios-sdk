//
//  CastledSessions.swift
//  Castled
//
//  Created by antony on 21/05/2024.
//

import Foundation

class CastledSessions: NSObject {
    @objc static var sharedInstance = CastledSessions()
    var userId = ""
    // var instanceId: String { CastledShared.sharedInstance.getCastledConfig().instanceId }
    private var isInitilized = false

    override private init() {}

    @objc public func initializeSessions() {
        if isInitilized {
            return
        }
        CastledRequestHelper.sharedInstance.registerHandlerWith(key: CastledConstants.CastledNetworkRequestType.sessionTracking.rawValue, handler: CastledSessionsRequestHandler.self)
        isInitilized = true
        CastledSessionsController.sharedInstance.initialize()
        //  CastledLog.castledLog("Sessions module initialized..", logLevel: CastledLogLevel.info)
    }

    func reportSessionEvents(params: [[String: Any]]) {
        if userId.isEmpty || CastledEnvironmentChecker.isRunningInDesignOrTestEnvironment() {
            return
        }
        CastledSessionRepository.reportSessionEvents(params: params)
    }
}
