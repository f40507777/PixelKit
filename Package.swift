// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "PixelKit",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13),
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "PixelKit", targets: ["PixelKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/heestand-xyz/RenderKit.git", .branch("lite")),
    ],
    targets: [
        .target(name: "PixelKit", dependencies: ["RenderKit"], path: "Source", exclude: [
            "PIX/PIXs/Output/Syphon Out/SyphonOutPIX.swift",
            "PIX/PIXs/Content/Resource/Syphon In/SyphonInPIX.swift",
            "PIX/Auto/PIXUIs.stencil",
            "PIX/Auto/PIXAuto.stencil",
            "Other/NDI",
            "Shaders/README.md",
        ], resources: [
            .process("metaltest.txt"),
            .process("metaltest.metal"),
        ]),
        .testTarget(name: "PixelKitTests", dependencies: ["PixelKit"])
    ]
)
