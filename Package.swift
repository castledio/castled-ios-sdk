// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

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
            targets: ["Castled", "CastledObjC"]
        ),
        .library(
            name: "CastledNotificationContent",
            targets: ["CastledNotificationContent"]
        ),
        .library(
            name: "CastledNotificationService",
            targets: ["CastledNotificationService"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.11.1"),
        .package(url: "https://github.com/realm/realm-cocoa.git", from: "10.43.0")
    ],
    targets: [
        .target(
            name: "Castled",
            dependencies: [
                "SDWebImage",
                .product(name: "RealmSwift", package: "realm-cocoa")
            ],
            path: "Sources/Castled",
            resources: [
                .process("InApps/Views/CastledAssets.xcassets"),
                .process("InApps/Views/Resources"),
                .process("Inbox/Views/Resources")
            ], linkerSettings: [
                .linkedFramework("AVFoundation"),
                .linkedFramework("UIKit"),
                .linkedFramework("UserNotifications")
            ]
        ),
        .target(
            name: "CastledObjC",
            dependencies: [
                "Castled"
            ],
            path: "Sources/CastledObjC",
            publicHeadersPath: ".",
            cSettings: [
                .define("SWIFT_PACKAGE")
            ],
            linkerSettings: [
                .linkedFramework("AVFoundation")
            ]
        ),

        .target(
            name: "CastledNotificationContent",
            dependencies: [
                "SDWebImage"
            ],
            path: "Sources/CastledNotificationContent/Swift",
            resources: [
                .process("ContentAssets.xcassets")
            ],
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
                .linkedFramework("AVFoundation")
            ]
        )
    ]
)
