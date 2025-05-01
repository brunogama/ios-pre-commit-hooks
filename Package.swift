// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "PreCommitInstaller",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(name: "PreCommitInstaller", targets: ["PreCommitInstaller"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "https://github.com/onevcat/Rainbow", from: "4.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "PreCommitInstaller",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "Rainbow",
                .product(name: "Yams", package: "Yams")
            ],
            path: "Sources"
        )
    ]
) 