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
        ),
        .library(
            name: "CastledInbox",
            targets: ["CastledInbox", "CastledInboxObjC"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.11.1")
    ],
    targets: [
        .target(
            name: "Castled",
            dependencies: [
                "SDWebImage"
            ],
            path: "Sources/Castled",
            resources: [
                .process("InApps/Views/CastledAssets.xcassets"),
                .process("InApps/Views/Resources")
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
            dependencies: [
                "Castled"
            ],
            path: "Sources/CastledNotificationService/Swift",
            linkerSettings: [
                .linkedFramework("AVFoundation")
            ]
        ),
        .target(
            name: "CastledInbox",
            dependencies: [
                "SDWebImage", "Castled"
            ],
            path: "Sources/CastledInbox",
            resources: [
                .process("Views/CastledInboxAssets.xcassets"),
                .process("Views/Resources")
            ], linkerSettings: [
                .linkedFramework("AVFoundation"),
                .linkedFramework("UIKit"),
                .linkedFramework("Coredata")
            ]
        ),
        .target(
            name: "CastledInboxObjC",
            dependencies: [
                "CastledInbox", "Castled"
            ],
            path: "Sources/CastledInboxObjC",
            publicHeadersPath: ".",
            cSettings: [
                .define("SWIFT_PACKAGE")
            ],
            linkerSettings: [
                .linkedFramework("AVFoundation")
            ]
        )
    ]
)
