// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Replicator11981",
	products: [
		.executable(name: "Replicator11981", targets: ["Replicator11981"])
	],
    dependencies: [
		.package(url: "https://github.com/apple/swift-package-manager.git", from: "0.1.0"),
		.package(url: "git@github.com:kayako/kayako-sdk-swift.git",  .branch("xcodegen")),
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Replicator11981",
			dependencies: ["Utility", "KayakoSDKSwift"]),
    ]
)
