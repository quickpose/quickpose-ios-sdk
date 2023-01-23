
# quickpose-ios-sdk

[![License](https://img.shields.io/github/license/quickpose/quickpose-ios-sdk)](https://raw.githubusercontent.com/quickpose/quickpose-ios-sdk/main/LICENSE) 
[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

QuickPose provides developer-oriented cutting edge ML features of MediaPipe and BlazePose. with easy integration, production ready code. Dramatically improving the speed of implementation of MediaPipe and BlazePose into mobile applications.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Features](#features)
- [Requirements](#requirements)
- [Installing the SDK](#installing-the-sdk)
  - [Swift Package Manager](#swift-package-manager)
- [Troubleshooting](#troubleshooting)
  - [No Such Module](#no-such-module)
  - [Unsupported Architecture](#unsupported-architecture)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


Features
------------------

| Feature       | Example       | Supported |
| ------------- |:-------------:| ---------:|
| MediaPipe Landmarks  |  | v0.1        |
| <p><b>Overlays</b></p><p>Whole Body</p><p>Upper Body</p><p>Lower Body</p><p>Shoulder</p><p>Left Arm</p><p>Right Arm</p><p>Left Leg</p><p>Right Leg</p>       |  ![Whole Body Overlay](docs/v0.1/overlay-whole-body.gif) ![Upper Body Overlay](docs/v0.1/overlay-upper-body.gif) ![Lower Body Overlay](docs/v0.1/overlay-lower-body.gif)  ![Shoulders Overlay](docs/v0.1/overlay-shoulders.gif)  ![Left Leg Overlay](docs/v0.1/overlay-left-leg.gif)  ![Right Leg Overlay](docs/v0.1/overlay-right-leg.gif)| v0.1        |


Requirements
------------------

- iOS 14.0+ 
- Xcode 10.0+

Installing the SDK
------------------

### Swift Package Manager

__Step 1__: Click on Xcode project file

__Step 2__: Click on Swift Packages and click on the plus to add a package

__Step 3__: Enter the following repository url `https://github.com/quickpose/quickpose-ios-sdk.git` and click next

![Import Package](docs/img/import-sdk-spm.gif)

__Step 4__: Choose all modules and click add package.

| Module        | Description         |
| --------------|--------------------:|
| QuickPoseCore | Core SDK (required) |
| QuickPoseMP   | Mediapipe Library (required) |
| QuickPoseSwiftUI | Utility Classes for SwiftUI Integration  (optional) |

Troubleshooting
------------------

### No Such Module

Xcode reports error no such module `QuickPoseCore` or no such module `QuickPoseSwiftUI`

> This happens when the linker cannot find the provided XCFrameworks. These needs to be included in the build. 

![xcode troubleshooting no such module error](docs/img/xcode-troubleshooting-no-such-module-error.png)

![xcode troubleshooting no such module guide](docs/img/xcode-troubleshooting-no-such-module.gif)

### Unsupported Architecture

Xcode reports error Could not build Objective-C module `QuickPoseCore` and `Unsupported Swift Architecture`.

> This happens when Xcode is trying to build for unsupported architectures probably, the iOS Simulator. Until these are supported choose `Build for Any iOS Device`.

![xcode troubleshooting unsupported swift architecture error](docs/img/xcode-troubleshooting-unsupported-swift-architecture-error.png)

![xcode troubleshooting unsupported swift architecture guide](docs/img/xcode-troubleshooting-unsupported-swift-architecture.gif)
