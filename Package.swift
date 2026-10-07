// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HabitFeature",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "HabitFeature", targets: ["HabitFeature"])
    ],
    dependencies: [
        .package(url: "https://github.com/ht9945/DesignKitForIOS.git", from: "0.5.0")
    ],
    targets: [
        .target(
            name: "HabitFeature",
            dependencies: [
                .product(name: "DesignKitForIOS", package: "DesignKitForIOS")
            ]
        )
    ]
)

