// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "PreCommitConfigs",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .executable(name: "pre-commit-configs", targets: ["PreCommitConfigs"]),
        .library(name: "Domain", targets: ["Domain"]),
        .library(name: "Infrastructure", targets: ["Infrastructure"]),
        .library(name: "Application", targets: ["Application"]),
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Rainbow", from: "4.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Domain",
            dependencies: [],
            path: "Sources/Domain"
        ),
        .target(
            name: "Infrastructure",
            dependencies: [
                "Domain",
                "Rainbow"
            ],
            path: "Sources/Infrastructure"
        ),
        .target(
            name: "Application",
            dependencies: [
                "Domain",
                "Infrastructure"
            ],
            path: "Sources/Application"
        ),
        .target(
            name: "PreCommitConfigs",
            dependencies: [
                "Domain",
                "Infrastructure",
                "Application",
                "Rainbow",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Sources/Utils"
        ),
    ]
) 