//
//  CastledPreferenceStoreListener.swift
//  Castled
//
//  Created by antony on 17/05/2024.
//

import Foundation
@_spi(CastledInternal)

public protocol CastledPreferenceStoreListener: AnyObject {
    func onStoreUserIdSet(_ userId: String)
}
