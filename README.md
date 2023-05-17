
# quickpose-ios-sdk


[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

QuickPose provides developer-oriented cutting edge ML features of MediaPipe and BlazePose, with easy integration and production ready code. Dramatically improving the speed of implementation of MediaPipe and BlazePose's pose estimation and skeleton tracking features into mobile applications. More documentation is provided at [https://docs.quickpose.ai/docs/MobileSDK](https://docs.quickpose.ai/docs/MobileSDK)

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Register an SDK Key](#register-an-sdk-key)
- [How it works](#how-it-works)
- [Features](#features)
- [Meta Features](#meta-features)
- [Supported Platforms](#supported-platforms)
- [Requirements](#requirements)
- [Installing the SDK](#installing-the-sdk)
  - [Swift Package Manager](#swift-package-manager)
- [Getting Started](#getting-started)
  - [Getting Started with Newer Macs M1/M2](#getting-started-with-newer-macs-m1m2)
  - [Getting Started with Older Intel Macs](#getting-started-with-older-intel-macs)
  - [SwiftUI Example](#swiftui-example)
- [Documentation](#documentation)
- [Troubleshooting](#troubleshooting)
  - [No Such Module](#no-such-module)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

Register an SDK Key
------------------

Get your free SDK key on [https://dev.quickpose.ai](https://dev.quickpose.ai), usage limits may apply. 
SDK Keys are linked to your bundle ID, please check Key before distributing to the App Store.

How it works
------------------

QuickPose process a video frame and makes it easy for developers to perform complex AI features to the image, such as overlaying markings to the output image to highlight the user's pose.

```swift
+----------+          +-------------+          +-----------------+
|          |          |             |          |  Overlay Image  |
|  Camera  |--------->|  QuickPose  |--------->|        +        |
|          |          |             |          |     Results     |
+----------+          +-------------+          +-----------------+
```

Features
------------------

| Feature       | Example       | Supported |
| ------------- |:-------------:| ---------:|
| MediaPipe Landmarks  | ![MediaPipe Landmarks](docs/v0.2/overlay-all-points.gif) | v0.1        |
| <p><b>Overlays</b></p><p>Whole Body</p><p>Upper Body</p><p>Lower Body</p><p>Shoulder</p><p>Left Arm</p><p>Right Arm</p><p>Left Leg</p><p>Right Leg</p>       |  ![Whole Body Overlay](docs/v0.1/overlay-whole-body.gif) ![Upper Body Overlay](docs/v0.1/overlay-upper-body.gif) ![Lower Body Overlay](docs/v0.1/overlay-lower-body.gif)  ![Shoulders Overlay](docs/v0.1/overlay-shoulders.gif)  ![Left Leg Overlay](docs/v0.1/overlay-left-leg.gif)  ![Right Leg Overlay](docs/v0.1/overlay-right-leg.gif)| v0.1        |
| <p><b>Health - Range Of Motion</b></p><p>Left Shoulder</p><p>Right Shoulder</p><p>Left Hip</p><p>Right Hip</p><p>Left Knee</p><p>Right Knee</p><p>Back</p><p>Neck</p>       |  ![health-shoulder-right-rom](docs/v0.3/health-shoulder-right-rom.gif) ![health-shoulder-rom](docs/v0.3/health-shoulder-rom.gif) ![health-hip-rom](docs/v0.3/health-hip-rom.gif) ![health-knee-rom](docs/v0.3/health-knee-rom.gif) ![health-back-rom](docs/v0.3/health-back-rom.gif)  ![health-neck-rom](docs/v0.3/health-neck-rom.gif)  | v0.3      |
| <p><b>Distance Independent Measuring Line <i>beta</i></b></p><p>Measurement relative to body height</p><p>Measurement in CM (using body height as input)</p>       |  ![feature-scale-independent-ruler](docs/v1.1.0/feature-scale-independent-ruler.gif) ![feature-scale-independent-ruler-cm](docs/v1.1.0/feature-scale-independent-ruler-cm.gif)  | v1.1.0    |
| <p><b>Fitness - Exercise Detection & Counter</b></p><p>Squat</p><p>Sumo Squat</p><p>Jumping Jack</p><p>Push Up</p> <p>Plank</p> <p>Cobra Wings</p>   <p>Left Leg Lunge</p><p>Right Leg Lunge</p><p> SitUps</p><p> CobraWings</p><p> Plank</p><p>Leg Raises</p><p>Glute Bridge</p><p>Overhead Dumbbell Press</p><p>vUps</p><p>Lateral Raises</p><p>Front Raises</p><p>Hip Abduction Standing Left</p><p>Hip Abduction Standing Right</p><p>Side Lunges Left</p><p>Side Lunges Right</p><p> Biceps Curls</p>|  ![fitness-pushup](docs/v0.8/fitness-pushup.gif) ![fitness-plank](docs/v0.8/fitness-plank.gif) ![fitness-cobra-wings](docs/v0.8/fitness-cobra-wings.gif) ![fitness-left-leg-lunges](docs/v0.8/fitness-left-leg-lunges.gif)  ![fitness-squats](docs/v0.8/fitness-squats.gif) ![fitness-sumo-squats](docs/v0.8/fitness-sumo-squats.gif) ![fitness-jumping-jacks](docs/v0.8/fitness-jumping-jacks.gif) ![fitness-sit-ups](docs/v0.8/fitness-sit-ups.gif) ![fitness-cobra-wings](docs/v0.8/fitness-cobra-wings.gif) ![fitness-plank](docs/v0.8/fitness-plank.gif)  ![fitness-overhead-dumbbell-press](docs/v1.1.0/fitness-overhead-dumbbell-press.gif) ![fitness-lateral-raises](docs/v1.1.0/fitness-lateral-raises.gif)![fitness-front-raises](docs/v1.1.0/fitness-front-raises.gif)![fitness-hip-abduction-standing](docs/v1.1.0/fitness-hip-abduction-standing.gif)![fitness-side-lunges](docs/v1.1.0/fitness-side-lunges.gif)![fitness-biceps-curls](docs/v1.1.0/fitness-biceps-curls.gif)![fitness-leg-raises](docs/v1.1.0/fitness-leg-raises.gif)  ![fitness-glute-bridge](docs/v1.1.0/fitness-glute-bridge.gif) ![fitness-v-ups](docs/v1.1.0/fitness-v-ups.gif)| v0.8 - v1.1.0|      
| <p><b>Input</b></p><p>Raised Finger Detection & Count</p>      | ![finger-counter-left](docs/v0.5/finger-counter-left.gif) ![finger-counter-right](docs/v0.5/finger-counter-right.gif)   | v0.5 |      
| <p><b>Input</b></p><p>Thumbs Up Detection, Thumbs up and down detection</p>      | ![thumbs-up](docs/v0.6/thumbs-up.gif) ![thumbs-up-and-down](docs/v0.6/thumbs-up-and-down.gif)   | v0.6 |     

Meta Features
------------------

| Feature       | Example       | Supported |
| ------------- |:-------------:| ---------:|
| Stacked Feature Styling | ![shoulder-conditional-image](docs/v0.4/bike-demo.gif)<br />[<small>Bike Side View Video by Tariq Ali</small>](https://www.youtube.com/watch?v=LRA4N5cGnLU) | v0.4 |   
| Conditional Styling | ![knee-conditional-image](docs/v0.4/health-knee-rom-conditional.gif) ![shoulder-conditional-image](docs/v0.4/health-shoulder-rom-conditional.gif)  | v0.4 |   
| <p><b>Fitness - Feedback</b></p><p>Body Position</p><p>Named Leg or Arm not visible</p> |   ![fitness-body-feedback](docs/v0.8/fitness-body-feedback.gif) ![fitness-arm-feedback](docs/v0.8/fitness-arm-feedback.gif) ![fitness-leg-feedback](docs/v0.8/fitness-leg-feedback.gif) | v0.8 |   
| Orientation Switching |   ![portrait](docs/v1.0.0/portrait.gif)  ![landscape](docs/v1.0.0/landscape.gif)  | v1.0.0 |       

Supported Platforms
------------------

| iOS Device | Silicon Mac (M1, M2, etc) | iOS Simulator x86_64 | iOS Simulator arm64  | 
| ----------:| -------------------------:|---------------------:|---------------------:|
| ✅ Runs    |                   ✅ Runs |          ⚙ Compiles |        ⚙ Known Issue |

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

![Import Package](docs/img/import-sdk-spm-fix.png)

__Step 4__: Choose all modules and click add package.

| Module        | Description         |
| --------------|--------------------:|
| QuickPoseCore | Core SDK (required) |
| QuickPoseMP   | Mediapipe Library (required) |
| QuickPoseCamera | Utility Class for Integration  (optional, recommended) |
| QuickPoseSwiftUI | Utility Classes for SwiftUI Integration  (optional, recommended)|



Getting Started
------------------

See code examples below or download our [Sample Apps](/SampleApps).

### Getting Started with Newer Macs M1/M2

__Step 1__: Download/Clone Repo

__Step 2__: Open Basic Demo

__Step 3__: Choose Build Target "My Mac (Designed For iPad/iPhone)"

__Step 4__: Run

![Getting Started With Mac Picture](docs/img/silicon-mac-get-started-upperbody.png)

__Step 5__: Explore the features and returned results

```swift
quickPose.start(features: [.overlay(.upperBody)], onFrame: { status, image, features, feedback, landmarks in
    if case .success(_) = status {
        overlayImage = image
    }
})
```

### Getting Started with Older Intel Macs

__Step 1__: Download/Clone Repo

__Step 2__: Open Basic Demo

__Step 3__: Choose Build Target as your physical device

__Step 5__: You will need to change the bundleid and register with apple if you haven't already.

__Step 5__: Run

__Step 6__: Explore the features and returned results

```swift
quickPose.start(features: [.overlay(.upperBody)], onFrame: { status, image, features,  feedback, landmarks in
    if case .success(_) = status {
        overlayImage = image
    }
})
```

### SwiftUI Example

```swift
import SwiftUI
import QuickPoseCore
import QuickPoseSwiftUI

....

struct QuickPoseBasicView: View {
    
    private var quickPose = QuickPose(sdkKey: "YOUR SDK KEY HERE") // register for your free key at https://dev.quickpose.ai
    @State private var overlayImage: UIImage?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                QuickPoseCameraView(useFrontCamera: true, delegate: quickPose)
                QuickPoseOverlayView(overlayImage: $overlayImage)
            }
            .frame(width: geometry.size.width)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                quickPose.start(features: [.overlay(.userLeftArm)], onFrame: { status, image, features,  feedback, landmarks in
                    if case .success(_) = status {
                        overlayImage = image
                    }
                })
            }.onDisappear {
                quickPose.stop()
            }
            
        }
    }
}
```

Documentation
------------------
Checkout our full documentation at [https://docs.quickpose.ai/docs/MobileSDK](https://docs.quickpose.ai/docs/MobileSDK) including more SwiftUI and UIKit examples.

Troubleshooting
------------------

### No Such Module

Xcode reports error no such module `QuickPoseCore` or no such module `QuickPoseSwiftUI`

> This happens when the linker cannot find the provided XCFrameworks. These needs to be added to your build Target. 

![xcode troubleshooting no such module error](docs/img/xcode-troubleshooting-no-such-module-error.png)

![xcode troubleshooting no such module guide](docs/img/xcode-troubleshooting-no-such-module-fix.png)

### Cannot find type 'QuickPoseCaptureAVAssetOutputSampleBufferDelegate' in scope

Xcode reports error `Cannot find type 'QuickPoseCaptureAVAssetOutputSampleBufferDelegate' in scope`

> This happens as our builds are not compatible with the arm64 simulator. To fix run as `My Mac (Designed for iPhone)`

![xcode troubleshooting cannot find type](docs/img/xcode-troubleshooting-cannot-find-type-arm64.png)
