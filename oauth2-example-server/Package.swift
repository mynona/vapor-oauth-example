// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "oauth2-example-server",
    platforms: [
       .macOS(.v13)
    ],
    dependencies: [
      .package(url: "https://github.com/vapor/vapor.git", from: "4.90.0"),
      .package(url: "https://github.com/vapor/fluent.git", from: "4.8.0"),
      .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.6.0"),
      .package(url: "https://github.com/vapor/leaf.git", from: "4.2.4"),
      .package(url: "https://github.com/vamsii777/vapor-oauth.git", from: "1.1.0-beta.3")
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Leaf", package: "leaf"),
                .product(name: "OAuth", package: "vapor-oauth")
            ]
        ),
        .executableTarget(name: "Run", dependencies: [.target(name: "App")])
    ]
)
