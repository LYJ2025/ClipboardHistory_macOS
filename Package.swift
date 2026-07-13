// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "ClipboardHistory",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "ClipboardHistory",
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ],
            linkerSettings: [
                .linkedFramework("Carbon")
            ]
        )
    ]
)
