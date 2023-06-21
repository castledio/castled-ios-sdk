// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Castled",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13)
    ],


    products: [
        .library(
            name: "Castled",
            targets: ["Castled"]),
        .library(
            name: "CastledNotificationContent",
            targets: ["CastledNotificationContent"]),
        .library(
            name: "CastledNotificationService",
            targets: ["CastledNotificationService"])
    ],
    dependencies: [
        .package(url: "https://github.com/castledio/castled-ios-sdk.git", branch: "SPM"),
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.11.1")
    ],
    targets: [
        .target(
            name: "Castled",
            path: "Sources/Castled",
            linkerSettings: [
                .linkedFramework("AVFoundation"),
                .linkedFramework("UIKit"),
                .linkedFramework("UserNotifications")
            ]
        ),
        .target(
            name: "CastledNotificationContent",
            dependencies: [
                "SDWebImage",
            ], path: "Sources/CastledNotificationContent/Swift",
            linkerSettings: [
                .linkedFramework("AVFoundation"),
                .linkedFramework("UIKit"),
                .linkedFramework("UserNotifications"),
                .linkedFramework("UserNotificationsUI")
            ]
            
        ),
        .target(
            name: "CastledNotificationService",
            path: "Sources/CastledNotificationService/Swift",
            linkerSettings: [
                .linkedFramework("AVFoundation")]
            
        )
    ]
)

