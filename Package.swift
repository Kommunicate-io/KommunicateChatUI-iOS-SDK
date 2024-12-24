// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "KommunicateChatUI-iOS-SDK",
    defaultLocalization: "en",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "KommunicateChatUI-iOS-SDK",
            targets: ["KommunicateChatUI-iOS-SDK"]
        ),
        .library(
            name: "RichMessageKit",
            targets: ["RichMessageKit"]
        ),
    ],
    dependencies: [
        .package(name: "KommunicateCore_iOS_SDK", url: "https://github.com/Kommunicate-io/KommunicateCore-iOS-SDK.git", from: "1.2.5"),
        .package(name: "Kingfisher", url: "https://github.com/onevcat/Kingfisher.git", .exact("7.6.2")),
        .package(name: "SwipeCellKit", url: "https://github.com/SwipeCellKit/SwipeCellKit.git", from: "2.7.1"),
        .package(name: "ZendeskChatProvidersSDK", url: "https://github.com/zendesk/chat_providers_sdk_ios",.exact("5.0.0")),
        .package(name: "iOSDropDown", url: "https://github.com/jriosdev/iOSDropDown.git", .upToNextMajor(from: "0.4.0"))
    ],
    targets: [
        .target(name: "KommunicateChatUI-iOS-SDK",
                dependencies: ["RichMessageKit",
                               .product(name: "KommunicateCore_iOS_SDK", package: "KommunicateCore_iOS_SDK"),
                               "Kingfisher",
                               "SwipeCellKit",
                               "ZendeskChatProvidersSDK",
                               "iOSDropDown"],
                path: "Sources",
                exclude: ["Extras"],
                linkerSettings: [
                    .linkedFramework("Foundation"),
                    .linkedFramework("SystemConfiguration"),
                    .linkedFramework("UIKit", .when(platforms: [.iOS])),
                ]),
        .target(name: "RichMessageKit",
                dependencies: [],
                path: "RichMessageKit",
                linkerSettings: [
                    .linkedFramework("Foundation"),
                    .linkedFramework("UIKit", .when(platforms: [.iOS])),
                ]),
    ]
)
