//
//  CastledResponse.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import Foundation

internal class CastledResponse<T: Any>: NSObject {

    let statusCode: Int
    public var success: Bool
    public var errorMessage: String
    public var result: T?

    init(error: String, statusCode: Int) {
        self.success = false
        self.errorMessage = error
        self.statusCode = statusCode
        self.result = nil
    }

    init(response: T) {
        self.success = true
        self.errorMessage = ""
        self.statusCode = 200
        self.result = response
    }
}
