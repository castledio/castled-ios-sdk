//
//  CastledShared.swift
//  Castled
//
//  Created by antony on 20/05/2024.
//

import Foundation
@_spi(CastledInternal)

public class CastledShared: NSObject {
    @objc public static var sharedInstance = CastledShared()

    override private init() {}
}
