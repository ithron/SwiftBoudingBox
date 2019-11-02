// swift-tools-version:4.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftBoundingBox",
  products: [
    .library(
      name: "SwiftBoundingBox",
      targets: ["SwiftBoundingBox"]),
  ],
  targets: [
    .target(
      name: "SwiftBoundingBox",
      dependencies: []),
    .testTarget(
      name: "SwiftBoundingBoxTests",
      dependencies: ["SwiftBoundingBox"]),
  ]
)
