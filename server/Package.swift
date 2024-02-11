// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "auth",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.92.1"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.8.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.3.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.6.0"),
        //.package(url: "https://github.com/vamsii777/vapor-oauth.git", from: "1.1.0-beta.4"),
        .package(url: "https://github.com/vamsii777/vapor-oauth.git", branch: "feature/openid"),
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.2.0")
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "OAuth", package: "vapor-oauth"),
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "Leaf", package: "leaf"),
            ]
        ),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
            
            // Workaround for https://github.com/apple/swift-package-manager/issues/6940
            .product(name: "Vapor", package: "vapor"),
            .product(name: "Fluent", package: "Fluent"),
            .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
            .product(name: "Leaf", package: "leaf"),
        ])
    ]
)
