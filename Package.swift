// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "WPCommand",
    defaultLocalization: "zh",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "WPCommand",
            targets: ["WPCommand"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.6.0"),
    ],
    targets: [
        .target(
            name: "WPCommand",
            dependencies: [
                "SnapKit",
            ],
            path: "Sources/WPCommand"
        )
    ]
)
