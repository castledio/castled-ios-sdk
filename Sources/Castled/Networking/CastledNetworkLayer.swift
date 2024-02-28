//
//  CastledNetworkLayer.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//
// Reference : https://medium.com/nerd-for-tech/using-url-sessions-with-swift-5-5-aysnc-await-codable-8935fe55fbfc

import Contacts
import Foundation

@objc class CastledNetworkLayer: NSObject {
    let retryLimit = 5
    static var shared = CastledNetworkLayer()
    override private init() {}

    func sendRequest<T: Codable>(model: T.Type, request: CastledNetworkRequest, retryAttempt: Int? = 0, isFetch: Bool = false) async -> CastledResponse<T> {
        if #available(iOS 13.0, *) {
            do {
                if CastledReachability.isConnectedToNetwork() == false {
                    return CastledResponse<T>(error: CastledExceptionMessages.common.rawValue, statusCode: 0)
                }
                guard let urlRequest = request.createRequest(with: request) else {
                    return CastledResponse<T>(error: CastledExceptionMessages.paramsMisMatch.rawValue, statusCode: 0)
                }
                if #available(iOS 13.0, *) {
                    let (data, response) = try await URLSession.shared.data(for: urlRequest)

                    if let httpResponse = response as? HTTPURLResponse, (200 ... 299).contains(httpResponse.statusCode) {
                        if isFetch {
                            do {
                                let decoder = JSONDecoder()
                                decoder.keyDecodingStrategy = .convertFromSnakeCase
                                let result = try decoder.decode(T.self, from: data)
                                return CastledResponse(response: result)

                            } catch {
                                // Inspect any thrown errors here.
                                return CastledResponse<T>(error: error.localizedDescription, statusCode: 0)
                            }
                        }
                        return CastledResponse<T>(response: ["success": "1"] as! T)

                    } else {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            if let error_message = json["message"] as? String {
                                return CastledResponse<T>(error: error_message, statusCode: 0)
                            }
                        }
                        return CastledResponse<T>(error: CastledExceptionMessages.common.rawValue, statusCode: 0)
                    }
                } else {
                    // Fallback on earlier versions
                }
            } catch {
                if retryAttempt! < retryLimit {
                    return await CastledNetworkLayer.shared.sendRequest(model: model, request: request, retryAttempt: retryAttempt! + 1, isFetch: isFetch)
                }
                return CastledResponse<T>(error: CastledExceptionMessages.common.rawValue, statusCode: 0)
            }
        }
        return CastledResponse<T>(error: CastledExceptionMessages.iOS13Less.rawValue, statusCode: 0)
    }
}
