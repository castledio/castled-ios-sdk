//
//  CastledNetworkRequest+Extensions.swift
//  Castled
//
//  Created by antony on 28/02/2024.
//

import Foundation

extension CastledNetworkRequest {
    private func createGetRequestWithURLComponents(url: URL) -> URLRequest? {
        var components = URLComponents(string: url.absoluteString)!
        if let parameters = parameters {
            var queryItems: [URLQueryItem] = []
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                queryItems.append(queryItem)
            }
            components.queryItems = queryItems
        }
        components.percentEncodedQuery = components.percentEncodedQuery?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        var request = URLRequest(url: components.url ?? url)
        request.httpMethod = method.rawValue
        request.setAuthHeaders()
        request.timeoutInterval = 30.0
        return request
    }

    private func createPostAndPutRequestWithBody(url: URL) -> URLRequest? {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        if let requestBody = getParameterBody(with: parameters!) {
            request.httpBody = requestBody
        }
        request.setAuthHeaders()
        request.timeoutInterval = 30.0
        return request
    }

    private func getParameterBody(with parameters: [String: Any]) -> Data? {
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) else {
            return nil
        }
        return httpBody
    }

    func createRequest(with path: String) -> URLRequest? {
        guard let url = URL(string: CastledNetworkLayer.shared.BASE_URL + path) else {
            CastledLog.castledLog("Invalid URL", logLevel: CastledLogLevel.error)
            return nil
        }

        switch method {
            case .get:
                return createGetRequestWithURLComponents(url: url)
            case .post, .put:
                return createPostAndPutRequestWithBody(url: url)
        }
    }
}
