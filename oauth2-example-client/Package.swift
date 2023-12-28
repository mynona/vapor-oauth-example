// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "oauth2-example-client",
    platforms: [
       .macOS(.v12)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.89.3"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.2.4"),
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.1.0"),
        .package(url: "https://github.com/vapor/jwt.git", from: "4.2.2")
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "Leaf", package: "leaf"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "JWT", package: "jwt")
            ]
        ),
        .executableTarget(name: "Run", dependencies: [.target(name: "App")])
    ]
)
