// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SnapKitExtend",
    
    platforms: [
        .iOS(.v12),
        .macOS(.v10_13),
        .tvOS(.v12)
    ],
    products: [
        .library(name: "SnapKitExtend", targets: ["SnapKitExtend"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit", .upToNextMajor(from: "5.0.0")),
    ],
    targets: [
        .target(
            name: "SnapKitExtend",
            dependencies: ["SnapKit"],
            path: "SnapKitExtend"
        )
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
