// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Browser",
    defaultLocalization: "ru",
    platforms: [
        .macOS(.v26)
    ],
    products: [
        .executable(name: "Browser", targets: ["BrowserApp"])
    ],
    targets: [
        .target(
            name: "BrowserCore",
            resources: [.process("Resources")]
        ),
        .target(
            name: "BrowserEngine",
            dependencies: ["BrowserCore"],
            resources: [.process("Resources")]
        ),
        .target(
            name: "BrowserPersistence",
            dependencies: ["BrowserCore"]
        ),
        .target(
            name: "BrowserUI",
            dependencies: ["BrowserCore", "BrowserEngine"],
            resources: [.process("Resources")]
        ),
        .executableTarget(
            name: "BrowserApp",
            dependencies: ["BrowserCore", "BrowserEngine", "BrowserPersistence", "BrowserUI"]
        ),
        .testTarget(
            name: "BrowserCoreTests",
            dependencies: ["BrowserCore"]
        ),
        .testTarget(
            name: "BrowserEngineTests",
            dependencies: ["BrowserEngine"]
        ),
        .testTarget(
            name: "BrowserPersistenceTests",
            dependencies: ["BrowserCore", "BrowserPersistence"]
        ),
        .testTarget(
            name: "BrowserUITests",
            dependencies: ["BrowserCore", "BrowserUI", "BrowserPersistence"]
        )
    ],
    swiftLanguageModes: [.v6]
)
