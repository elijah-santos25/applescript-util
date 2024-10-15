// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AppleScriptUtil",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "AppleScriptUtil",
            targets: ["AppleScriptUtil"]),
    ],
    targets: [
        .target(
            name: "AppleScriptUtil"),

    ]
)
