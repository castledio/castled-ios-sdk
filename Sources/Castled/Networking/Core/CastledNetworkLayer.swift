//
//  CastledNetworkLayer.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//
// Reference : https://medium.com/nerd-for-tech/using-url-sessions-with-swift-5-5-aysnc-await-codable-8935fe55fbfc

import Contacts
import Foundation
@_spi(CastledInternal)

public class CastledNetworkLayer: NSObject {
    var BASE_URL: String {
        return "https://\(CastledConfigsUtils.configs.location.description).castled.io/backend/"
    }

    let retryLimit = 5
    public static var shared = CastledNetworkLayer()
    override private init() {}

    func sendRequestWith<T: Codable>(request: CastledNetworkRequest, path: String, responseModel: T.Type, retryAttempt: Int? = 0, shouldDecodeResponse: Bool = false) async -> CastledResponse<T> {
        if #available(iOS 13.0, *) {
            do {
                if CastledReachability.isConnectedToNetwork() == false {
                    return CastledResponse<T>(error: CastledExceptionMessages.common.rawValue, statusCode: 0)
                }
                guard let urlRequest = request.createRequest(with: path) else {
                    return CastledResponse<T>(error: CastledExceptionMessages.paramsMisMatch.rawValue, statusCode: 0)
                }
                if #available(iOS 13.0, *) {
                    let (data, response) = try await URLSession.shared.data(for: urlRequest)

                    if let httpResponse = response as? HTTPURLResponse, (200 ... 299).contains(httpResponse.statusCode) {
                        if shouldDecodeResponse { // this usin only fer fetch inbox/inapps rest all are jus returning the success
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
                        var statusCode = 0
                        var errorMsg = CastledExceptionMessages.common.rawValue
                        if let httpResponse = response as? HTTPURLResponse, !shouldDecodeResponse,
                           httpResponse.statusCode.shouldIgnoreErrorCode()
                        { // Ignoring 400 series error
                            statusCode = httpResponse.statusCode
                            errorMsg = "Invalid input params"
                        }
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let error_message = json["message"] as? String {
                            errorMsg = error_message
                        }
                        return CastledResponse<T>(error: "\(errorMsg) with params \(String(describing: request.parameters))", statusCode: statusCode)
                    }
                } else {
                    // Fallback on earlier versions
                }
            } catch {
                if retryAttempt! < retryLimit {
                    return await CastledNetworkLayer.shared.sendRequestWith(request: request, path: path, responseModel: responseModel, retryAttempt: retryAttempt! + 1, shouldDecodeResponse: shouldDecodeResponse)
                }
                return CastledResponse<T>(error: CastledExceptionMessages.common.rawValue, statusCode: 0)
            }
        }
        return CastledResponse<T>(error: CastledExceptionMessages.iOS13Less.rawValue, statusCode: 0)
    }

    public func makeApiCall<T: Codable>(request: CastledNetworkRequest, path: String, responseModel: T.Type = [String: String].self, shouldDecodeResponse: Bool = false, withRetry: Bool = false, completion: @escaping (_ response: CastledResponse<T>) -> Void) {
        Task {
            let api_response = await CastledNetworkLayer.shared.sendRequestWith(request: request, path: path, responseModel: responseModel, shouldDecodeResponse: shouldDecodeResponse)
            if !api_response.success, !shouldDecodeResponse {
                // handle api failure for reporting
                if api_response.statusCode.shouldIgnoreErrorCode() {
                    if withRetry {
                        // not enqueueing the request as 400 series
                        completion(api_response)
                    } else {
                        // retuens success to remove from the  queue if any for 400 series
                        // this is for retry
                        completion(CastledResponse<T>(response: ["success": "1"] as! T))
                    }
                    return
                }
                if withRetry {
                    // adding the requests to the queue for other errors
                    CastledStore.enqueFailedRequest(request)
                }
            }
            completion(api_response)
        }
    }
}

private extension Int {
    func shouldIgnoreErrorCode() -> Bool {
        return (400 ... 499).contains(self)
    }
}
