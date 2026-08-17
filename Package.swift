// swift-tools-version: 6.3.3

import PackageDescription

let package = Package(
    name: "swift-stores",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(
            name: "Stores",
            targets: ["Stores"]
        ),
        .library(
            name: "Stores Testing",
            targets: ["Stores Testing"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-primitives/swift-store-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-tree-keyed-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-deque-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-queue-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-dictionary-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-dictionary-ordered-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-hash-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-algebra-primitives.git",
            branch: "main"
        ),
        .package(url: "https://github.com/swift-foundations/swift-effects.git", branch: "main"),
        .package(
            url: "https://github.com/swift-foundations/swift-observations.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-foundations/swift-dependencies.git",
            branch: "main"
        ),
        .package(url: "https://github.com/swift-foundations/swift-clocks.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Stores",
            dependencies: [
                .product(name: "Store Reduction Primitives", package: "swift-store-primitives"),
                .product(name: "Tree Keyed Primitives", package: "swift-tree-keyed-primitives"),
                .product(name: "Deque Primitives", package: "swift-deque-primitives"),
                .product(name: "Queue Primitive", package: "swift-queue-primitives"),
                .product(name: "Dictionary Primitive", package: "swift-dictionary-primitives"),
                .product(
                    name: "Dictionary Ordered Primitives",
                    package: "swift-dictionary-ordered-primitives"
                ),
                .product(name: "Hash Primitives", package: "swift-hash-primitives"),
                .product(name: "Algebra Monoid Primitives", package: "swift-algebra-primitives"),
                .product(name: "Effects", package: "swift-effects"),
                .product(name: "Observations", package: "swift-observations"),
                .product(name: "Dependencies", package: "swift-dependencies"),
            ]
        ),
        .target(
            name: "Stores Testing",
            dependencies: [
                "Stores",
                .product(name: "Store Reduction Primitives", package: "swift-store-primitives"),
                .product(name: "Effects", package: "swift-effects"),
                .product(name: "Clocks", package: "swift-clocks"),
            ]
        ),
        .testTarget(
            name: "Stores Tests",
            dependencies: [
                "Stores",
                "Stores Testing",
                .product(name: "Algebra Monoid Primitives", package: "swift-algebra-primitives"),
            ]
        ),
        .testTarget(
            name: "Stores Testing Tests",
            dependencies: [
                "Stores",
                "Stores Testing",
                .product(name: "Clocks", package: "swift-clocks"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
