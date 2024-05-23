//
//  CastledDeviceInfoRepository.swift
//  Castled
//
//  Created by antony on 21/05/2024.
//

import Foundation

enum CastledDeviceInfoRepository {
    static let eventsPath = "external/v1/collections/devices"

    static func getEventsRequest(params: [String: Any]) -> CastledNetworkRequest {
        return CastledNetworkRequest(
            type: CastledConstants.CastledNetworkRequestType.deviceInfoRequest.rawValue,
            method: .post,
            parameters: ["type": "track", "deviceInfo": params, "userId": CastledDeviceInfo.sharedInstance.userId])
    }

    static func reportDeviceInfoEvents(params: [String: Any]) {
        let request = CastledDeviceInfoRepository.getEventsRequest(params: params)
        CastledNetworkLayer.shared.makeApiCall(request: request, path: eventsPath, withRetry: true) { _ in
        }
    }
}
