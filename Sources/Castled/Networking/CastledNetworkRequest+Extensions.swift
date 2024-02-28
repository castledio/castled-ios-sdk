//
//  CastledNetworkRequest+Extensions.swift
//  Castled
//
//  Created by antony on 28/02/2024.
//

import Foundation

extension CastledNetworkRequest {
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
        components.percentEncodedQuery = components.percentEncodedQuery?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        var request = URLRequest(url: components.url ?? url)
        request.httpMethod = castled_request.method.rawValue
        request.setAuthHeaders()
        return request
    }

    private func createPostAndPutRequestWithBody(url: URL, castled_request: CastledNetworkRequest) -> URLRequest? {
        var request = URLRequest(url: url)
        request.httpMethod = castled_request.method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        if let requestBody = getParameterBody(with: castled_request.parameters!) {
            request.httpBody = requestBody
        }
        request.setAuthHeaders()
        return request
    }

    private func getParameterBody(with parameters: [String: Any]) -> Data? {
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) else {
            return nil
        }
        return httpBody
    }

    private func constructURL(for endpoint: CastledNetworkRequest) -> URL? {
        let urlString = endpoint.baseURL + endpoint.baseURLEndPoint + endpoint.path
        return URL(string: urlString)
    }

    func createRequest(with endpoint: CastledNetworkRequest) -> URLRequest? {
        guard let url = constructURL(for: endpoint) else {
            CastledLog.castledLog("Invalid URL", logLevel: CastledLogLevel.error)
            return nil
        }

        switch endpoint.method {
            case .get:
                return createGetRequestWithURLComponents(url: url, castled_request: endpoint)
            case .post, .put:
                return createPostAndPutRequestWithBody(url: url, castled_request: endpoint)
        }
    }
}
