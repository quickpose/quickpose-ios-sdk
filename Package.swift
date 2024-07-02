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
    .library(name: "QuickPoseMP", targets: ["QuickPoseMPTarget-all"]),
    .library(name: "QuickPoseMP-heavy", targets: ["QuickPoseMPTarget-heavy"]),
    .library(name: "QuickPoseMP-full", targets: ["QuickPoseMPTarget-full"]),
    .library(name: "QuickPoseMP-lite", targets: ["QuickPoseMPTarget-lite"]),
    .library(name: "QuickPoseSwiftUI", targets: ["QuickPoseSwiftUI"]),
    .library(name: "QuickPoseCamera", targets: ["QuickPoseCamera"]),
  ],
  dependencies: [],
  targets: [
    
    .binaryTarget(name: "QuickPoseMP", path: "QuickPoseMP.xcframework"),
    .target(name: "QuickPoseMPTarget-all", dependencies: ["QuickPoseMP",], path: "QuickPoseMPWrapper",  linkerSettings: [.linkedLibrary("c++")]),

    .binaryTarget(name: "QuickPoseMP-heavy", path: "QuickPoseMP-heavy.xcframework"),
    .target(name: "QuickPoseMPTarget-heavy", dependencies: ["QuickPoseMP-heavy",], path: "QuickPoseMPWrapper-heavy", linkerSettings: [.linkedLibrary("c++")]),
    
    .binaryTarget(name: "QuickPoseMP-full", path: "QuickPoseMP-full.xcframework"),
    .target(name: "QuickPoseMPTarget-full", dependencies: ["QuickPoseMP-full",], path: "QuickPoseMPWrapper-full", linkerSettings: [.linkedLibrary("c++")]),
    
    .binaryTarget(name: "QuickPoseMP-lite", path: "QuickPoseMP-lite.xcframework"),
    .target(name: "QuickPoseMPTarget-lite", dependencies: ["QuickPoseMP-lite",], path: "QuickPoseMPWrapper-lite",  linkerSettings: [.linkedLibrary("c++")]),
    
    .binaryTarget(name: "QuickPoseCore", path: "QuickPoseCore.xcframework"),
    .target(name: "QuickPoseCoreTarget", dependencies: ["QuickPoseCore"], path: "QuickPoseCoreWrapper"),
    
    .target(name: "QuickPoseCamera", dependencies: ["QuickPoseCore"]),
    .target(name: "QuickPoseSwiftUI", dependencies: ["QuickPoseCamera"]),
  ]
)
