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
    let castledConfig = Castled.sharedInstance.getCastledConfig()
    private var isInitilized = false

    override private init() {}

    @objc public func initializeSessions() {
        if isInitilized {
            return
        }
        isInitilized = true
        CastledRequestHelper.sharedInstance.requestHandlerRegistry[CastledConstants.CastledNetworkRequestType.sessionTracking.rawValue] = CastledSessionsRequestHandler.self
        CastledSessionsController.sharedInstance.initialize()
        CastledLog.castledLog("Sessions module initilized!", logLevel: CastledLogLevel.info)
    }

    func reportSessionEvents(params: [[String: Any]]) {
        CastledSessionRepository.reportSessionEvents(params: params)
    }
}
