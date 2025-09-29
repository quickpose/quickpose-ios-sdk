# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v1.2.12 - 2025-09-29
### Added
- Overarm Reach and Knee Raises

## v1.2.12 - 2025-07-24

### Fixed
- Setting Style's relativeFontSize to 0, skips drawing

## v1.2.11 - 2025-07-21

### Fixed
- Setting Style's RelativeLineWidth to 0, skips drawing

## v1.2.10 - 2025-01-28

### Fixed
- Measuring line feature output

## v1.2.9 - 2024-06-25

### Fixed
- arm64/x86_64 Simulator compile
- Cocoapods arm64/x86_64 simulator
- Reduce bundle size with selecting a model complexity

## v1.2.8 - 2024-06-24

### Fixed
- onFrame Memory Leak
- BodyPoseClassifier leak

## v1.2.5 - 2023-10-24

### Fixed
- iOS17 Performance

## v1.2.4 - 2023-10-05

### Added
- OS Screen Recording Demo
- SDK Video Recording Demo

### Fixed
- iOS17 Compatibility

## v1.2.2 - 2023-07-11

### Added
- Raw Camera frame is now returned in .success enum status.

### Fixed
- Memory leak



## v1.2.1 - 2023-07-04

### Added
- Add Post Processing, so QuickPose can now achieve lag-free rendering at any fps. 

### Changed
- Upgraded Mediapipe to 10.1
- onStart callback returns after Mediapipe is loaded, not on first camera frame.

## v1.2.0 - 2023-06-21

### Added
- Inside box feature and overlay. Defaults to whole body but any joint group can be used.
- High Performance guide

### Changed
- Library performance under high framerates
- Improving readability of landmarks, by replacing raw double array with scaled Point3d lookups.
- Tidying up features by passing side as a parameter e.g. .userRightKnee -> .knee(side: .right)
- Simplified Feedback text to reuse QuickPose.Landmark.Group


## v1.1.1 - 2023-06-05

### Added
- Support for Cocoapods, with Cocoapods SwiftUI Sample App

### Changed
- Interface for Timers and Counters now more detailed and consistent. 

## v1.1.0 - 2023-05-17

### Added
- New Fitness exercises Leg Raises, Glute Bridge, Overhead Dumbbell Press, vUps, Lateral Raises, Front Raises, Hip Abduction Standing Left, Hip Abduction Standing Right, Side Lunges Left, Side Lunges Right, Biceps Curls.
- Scale Independent Measuring Line

### Fixed
- Orientation bug when starting app 'face up'


## v1.0.0 - 2023-05-09

### Added
- Landscape support and example
- Renamed guidance prompts to feedback prompts
- Sustained 60fps with per frame performance tuning

## v0.8 - 2023-04-26

### Added
- Depth Measurement Bar for Fitness Measurements
- Supporting Sumo Squats, Plank, Left and Right Leg Lunges and Cobra wings.
- Fitness Measurements return customizable guidance prompts
- Improved Camera Permissions for UIKit demo apps
- Fixed a stability issue where frames could be processed before initialisation

## v0.7 - 2023-03-20

### Fixed
- Archive Bug


## v0.6 - 2023-03-15

### Added
- Thumbs up and Thumbs Down detection feature
- Unchanged Detectors to observe when a user is holding in place for a specified period of time.

## v0.5 - 2023-03-02

### Added
- Raised finger detection and counting
- Updated Picker demo with new features

### Changed
- Extended QuickPoseThresholdCounter to be easier to work with including state change callback and transparency over internal state.

### Fixed
- Pressup counter is more robust

## v0.4 - 2023-02-22

### Added
- Custom overlay's line width, font size, and color.
- A conditional color based on measured angle

## v0.3 - 2023-02-14

### Added
- Health Range of Motion Measurements for Shoulder, Knee, Hip, Back and Neck
- Fitness Exercise Detection & Counters for Jumping Jacks and Squats.

## v0.2 - 2023-01-31

### Added
- Support for compiling on iOS Simulators
- Support for running on M1/M2 Mac's with Designed for iPhone/iPad
- Support for loading local video files

### Fixed
- Unsupported Architecture's bug, where Xcode reports error Could not build Objective-C module QuickPoseCore and Unsupported Swift Architecture.

## v0.1 - 2023-01-18

### Added
- Initial Release

