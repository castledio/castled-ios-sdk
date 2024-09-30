//
//  CastledNotificationDelegate.swift
//  Castled
//
//  Created by antony on 23/09/2024.
//

@objc public protocol CastledNotificationDelegate {
    @objc optional func notificationClicked(withNotificationType type: CastledNotificationType, buttonAction: CastledButtonAction, userInfo: [AnyHashable: Any])
    @objc optional func didReceiveCastledRemoteNotification(withInfo userInfo: [AnyHashable: Any])
}
