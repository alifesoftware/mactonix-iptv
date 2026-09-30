// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "macnotix-iptv",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "Macnotix",
            targets: ["Macnotix"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "Macnotix",
            dependencies: [],
            path: "Sources/Macnotix",
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "MacnotixTests",
            dependencies: ["Macnotix"],
            path: "Tests/MacnotixTests"
        )
    ]
)
