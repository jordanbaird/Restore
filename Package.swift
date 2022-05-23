// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "Restore",
    products: [
        .library(
            name: "Restore",
            targets: ["Restore"]
        ),
    ],
    dependencies: [
      .package(
        url: "https://github.com/apple/swift-docc-plugin",
        from: "1.0.0"
      ),
    ],
    targets: [
        .target(
            name: "Restore",
            dependencies: []
        ),
        .testTarget(
            name: "RestoreTests",
            dependencies: ["Restore"]
        ),
    ]
)
