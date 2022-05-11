// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Tenta",
    platforms: [
        .macOS("12.0")
    ],
    products: [
        .library(
            name: "Tenta",
            targets: ["Tenta"]
        )
    ],
    targets: [
        .target(
            name: "Tenta",
            dependencies: [],
            path: "Tenta"
        ),
        .testTarget(
            name: "TentaTests",
            dependencies: ["Tenta"],
            path: "TentaTests"
        )
    ]
)
