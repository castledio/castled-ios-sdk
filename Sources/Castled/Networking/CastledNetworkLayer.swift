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
    private var request: URLRequest?
    override private init() {}

    private func createGetRequestWithURLComponents(url: URL, castled_request: CastledNetworkRequest) -> URLRequest? {
        var components = URLComponents(string: url.absoluteString)!
        if let parameters = castled_request.parameters {
            var queryItems: [URLQueryItem] = []
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                queryItems.append(queryItem)
            }
            components.queryItems = queryItems
        }
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        request = URLRequest(url: components.url ?? url)
        request?.httpMethod = castled_request.method.rawValue
        return request
    }

    private func createPostAndPutRequestWithBody(url: URL, castled_request: CastledNetworkRequest) -> URLRequest? {
        request = URLRequest(url: url)
        request?.httpMethod = castled_request.method.rawValue
        request?.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request?.addValue("application/json", forHTTPHeaderField: "Accept")

        if let headers = castled_request.headers {
            for (key, value) in headers {
                request?.setValue(value, forHTTPHeaderField: key)
            }
        }

        if let requestBody = getParameterBody(with: castled_request.parameters!) {
            request?.httpBody = requestBody
        }
        return request
    }

    private func getParameterBody(with parameters: [String: Any]) -> Data? {
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) else {
            return nil
        }
        return httpBody
    }

    func createRequest(with endpoint: CastledNetworkRequest) -> URLRequest? {
        guard let url = constructURL(for: endpoint) else {
            CastledLog.castledLog("Invalid URL", logLevel: CastledLogLevel.error)
            return nil
        }

        switch endpoint.method {
        case .get:
            return createGetRequestWithURLComponents(url: url, castled_request: endpoint)
        case .post:
            return createPostAndPutRequestWithBody(url: url, castled_request: endpoint)
        case .put:
            return createPostAndPutRequestWithBody(url: url, castled_request: endpoint)
        }
    }

    func constructURL(for endpoint: CastledNetworkRequest) -> URL? {
        let urlString = endpoint.baseURL + endpoint.baseURLEndPoint + endpoint.path
        return URL(string: urlString)
    }

    func sendRequest<T: Codable>(model: T.Type, request: CastledNetworkRequest, retryAttempt: Int? = 0, isFetch: Bool = false) async -> CastledResponse<T> {
        if #available(iOS 13.0, *) {
            do {
                if CastledReachability.isConnectedToNetwork() == false {
                    return CastledResponse<T>(error: CastledExceptionMessages.common.rawValue, statusCode: 0)
                }
                guard let urlRequest = createRequest(with: request) else {
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
