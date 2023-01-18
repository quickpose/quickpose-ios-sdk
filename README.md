
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
- [Getting Started](#getting-started)
  - [Integrating into SwiftUI App](#integrating-into-swiftui-app)
  - [Integrating into UIKit App](#integrating-into-uikit-app)
- [Troubleshooting](#troubleshooting)
  - [No Such Module](#no-such-module)
  - [Unsupported Architecture](#unsupported-architecture)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


Features
------------------

| Feature       | Example       | Supported |
| ------------- |:-------------:| ---------:|
| MediaPipe Landmarks  | ![MediaPipe Landmarks](docs/v0.2/overlay-all-points.gif) | v0.1        |
| <p><b>Overlays</b></p><p>Whole Body</p><p>Upper Body</p><p>Lower Body</p><p>Shoulder</p><p>Left Arm</p><p>Right Arm</p><p>Left Leg</p><p>Right Leg</p>       |  ![Whole Body Overlay](docs/v0.1/overlay-whole-body.gif) ![Upper Body Overlay](docs/v0.1/overlay-upper-body.gif) ![Lower Body Overlay](docs/v0.1/overlay-lower-body.gif)  ![Shoulders Overlay](docs/v0.1/overlay-shoulders.gif)  ![Left Leg Overlay](docs/v0.1/overlay-left-leg.gif)  ![Right Leg Overlay](docs/v0.1/overlay-right-leg.gif)| v0.1        |


Supported Platforms
------------------

| iOS Device | M1/M2 Mac (Running as Designed for iPad) | iOS Simulator x86_64 | iOS Simulator arm64  | 
| ----------:| ----------------------------------------:|---------------------:|---------------------:|
| ✅ Runs    |                                 ✅ Runs |            ⚙ Compiles |         ⚙ Compiles  |

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
| QuickPoseCamera | Utility Class for UIKit Integration  (optional) |
| QuickPoseSwiftUI | Utility Classes for SwiftUI Integration  (optional) |

Getting Started
------------------

See code examples below or download our [Sample Apps](/SampleApps).

### Integrating into SwiftUI App

```swift
import SwiftUI
import QuickPoseCore
import QuickPoseSwiftUI

....

struct QuickPoseBasicView: View {
    
    private var quickPose = QuickPose()
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
                quickPose.start(features: [.overlay(.userLeftArm)], onFrame: { status, image, features, landmarks in
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

### Integrating into UIKit App

```swift
import QuickPoseCore
import QuickPoseCamera
...

class ViewController: UIViewController {
    
    var camera: QuickPoseCamera?
    var quickPose = QuickPose()
    
    @IBOutlet var cameraView: UIView!
    @IBOutlet var overlayView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup camera
        camera = QuickPoseCamera(useFrontCamera: true)
        try? camera?.start(delegate: quickPose)
        
        let customPreviewLayer = AVCaptureVideoPreviewLayer(session: camera!.session!)
        customPreviewLayer.videoGravity = .resizeAspectFill
        customPreviewLayer.frame.size = view.frame.size
        cameraView.layer.addSublayer(customPreviewLayer)
        
        // setup overlay
        overlayView.contentMode = .scaleAspectFill // keep overlays in same scale as camera output
        overlayView.frame.size = view.frame.size
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        quickPose.start(features: [.overlay(.userLeftArm)], onFrame: { status, image, features, landmarks in
            if case .success(_) = status {
                DispatchQueue.main.async {
                    self.overlayView.image = image
                }
            }
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        camera?.stop()
        quickPose.stop()
    }
}
```


Troubleshooting
------------------

### No Such Module

Xcode reports error no such module `QuickPoseCore` or no such module `QuickPoseSwiftUI`

> This happens when the linker cannot find the provided XCFrameworks. These needs to be added to your build Target. 

![xcode troubleshooting no such module error](docs/img/xcode-troubleshooting-no-such-module-error.png)

![xcode troubleshooting no such module guide](docs/img/xcode-troubleshooting-no-such-module-fix.png)
