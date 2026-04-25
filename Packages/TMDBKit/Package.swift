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
    targets: [
        .target(
            name: "TMDBKit"
        ),
        .testTarget(
            name: "TMDBKitTests",
            dependencies: ["TMDBKit"]
        ),
    ]
)
