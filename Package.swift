// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "AnalyticsApi",
    platforms: [
        .iOS(.v12),
        .watchOS(.v6),
        .tvOS(.v13),
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "AnalyticsApi", targets: ["AnalyticsApi"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "AnalyticsApi"),
        .testTarget(
            name: "AnalyticsApiTests",
            dependencies: ["AnalyticsApi"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
