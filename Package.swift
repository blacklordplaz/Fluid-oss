// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Fluid",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/mxcl/AppUpdater.git", from: "1.0.0"),
        .package(url: "https://github.com/FluidInference/FluidAudio", from: "0.5.0")
    ],
    targets: [
        .executableTarget(
            name: "Fluid",
            dependencies: [
                "AppUpdater",
                "FluidAudio"
            ]
        )
    ]
)
