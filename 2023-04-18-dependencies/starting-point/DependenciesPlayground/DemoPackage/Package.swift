// swift-tools-version: 5.7
import PackageDescription

let package = Package(
  name: "DemoPackage",
  platforms: [.iOS(.v16)],
  products: [
    .library(
      name: "DemoPackage",
      targets: ["DemoPackage"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "0.1.0"),
  ],
  targets: [
    .target(
      name: "DemoPackage",
      dependencies: [.product(name: "Dependencies", package: "swift-dependencies")]),
  ]
)
