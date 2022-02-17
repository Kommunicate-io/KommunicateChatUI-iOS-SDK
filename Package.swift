// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "KommunicateChatUI-iOS-SDK",
    defaultLocalization: "en",
    platforms: [.iOS(.v12)],
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
        .package(name: "Applozic", url: "https://github.com/AppLozic/Applozic-Chat-iOS-Framework.git", .exact("8.3.0")),
            .package(name: "Kingfisher", url: "https://github.com/onevcat/Kingfisher.git", .exact("7.0.0")),
        .package(name: "SwipeCellKit", url: "https://github.com/SwipeCellKit/SwipeCellKit.git", from: "2.7.1"),
    ],
    targets: [
        .target(name: "KommunicateChatUI-iOS-SDK",
                dependencies: ["RichMessageKit",
                               .product(name: "ApplozicCore", package: "Applozic"),
                               "Kingfisher",
                               "SwipeCellKit"],
                path: "Sources",
                exclude: ["Extras"],
                resources: [.process("Resources")],
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
