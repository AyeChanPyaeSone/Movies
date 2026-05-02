// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "LoggingKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "LoggingKit",
            targets: ["LoggingKit"]
        ),
    ],
    targets: [
        .target(
            name: "LoggingKit"
        ),
        .testTarget(
            name: "LoggingKitTests",
            dependencies: ["LoggingKit"]
        ),
    ]
)
