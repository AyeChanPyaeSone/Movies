// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "TMDBKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "TMDBKit",
            targets: ["TMDBKit"]
        ),
    ],
    dependencies: [
        .package(path: "../LoggingKit"),
    ],
    targets: [
        .target(
            name: "TMDBKit",
            dependencies: ["LoggingKit"]
        ),
        .testTarget(
            name: "TMDBKitTests",
            dependencies: ["TMDBKit"]
        ),
    ]
)
