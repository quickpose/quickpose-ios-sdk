// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "quickpose-ios-sdk",
    platforms: [
        .iOS(.v14)
    ],
  products: [
    .library(name: "QuickPoseCore", targets: ["QuickPoseCoreTarget"]),
    .library(name: "QuickPoseMP", targets: ["QuickPoseMPTarget"]),
    .library(name: "QuickPoseSwiftUI", targets: ["QuickPoseSwiftUI"]),
  ],
  dependencies: [],
  targets: [
    .target(name: "QuickPoseSwiftUI"),
    .target(name: "QuickPoseCoreTarget", dependencies: ["QuickPoseCore"], path: "QuickPoseCoreWrapper"),
    .target(name: "QuickPoseMPTarget", dependencies: ["QuickPoseMP",], path: "QuickPoseMPWrapper", linkerSettings: [.linkedLibrary("c++")]),
    
    .binaryTarget(name: "QuickPoseCore", path: "QuickPoseCore.xcframework"),
    .binaryTarget(name: "QuickPoseMP", path: "QuickPoseMP.xcframework"),
  ]
)
