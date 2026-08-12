# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v1.5.1 - 2026-08-12

### Fixed
- `.fitness(.frontPushUps)` now counts reps when filmed head-on: the posture gate wrongly returned 0 for every front-facing frame (it tested for a side-on horizontal torso), and a full elbow bend never projected down to the 90° bottom angle, stalling legitimate reps below the rep-counting threshold. The gate now tests directly for an upright body, and the bottom angle accounts for head-on foreshortening
- Corrected the `.frontPushUps` display title typo

## v1.5.0 - 2026-08-11

### Changed
- `QuickPoseCamera` now defaults to the widest field of view the selected camera offers — typically the sensor-native 4:3 format (e.g. 1440×1080) instead of a 16:9 centre crop. Apps see noticeably more of the scene (on front cameras this matches the stock Camera app's "zoomed out" selfie framing), and the capture aspect ratio changes from 16:9 to 4:3

## v1.4.0 - 2026-08-02

### Added
- Five new fitness exercises on `QuickPose.FitnessFeature`:
  - `.burpees` — full stand → squat → floor → stand sequence; a squat without the floor stage does not count
  - `.shoulderTaps` — high plank, hand to opposite shoulder; each tap counts
  - `.mountainClimbers` — high plank, alternate knee drives; each drive counts
  - `.highKneeTaps` — standing alternate knee raises; each raise counts
  - `.boxing` — guard ↔ jab/cross; each punch counts

### Fixed
- Exercise state fully resets on `start()` and when an exercise is newly added via `update(features:)`, so a previous session can no longer influence rep counting
- `stop()` now stops frame processing immediately, preventing a queued frame from being processed after teardown

## v1.3.0 - 2026-07-15

### Added
- Overlay styling options on `QuickPose.Style`:
  - `lineCap` — `.round` (default), `.butt`, `.square`
  - `linePattern` — `.solid`, `.dashed`, `.dotted`
  - `shadow` — drop shadow behind lines, points and labels; a zero-offset shadow in the line's own color renders as a glow
  - `outline` — contrasting border behind lines and points, keeping the overlay legible on any background
  - `imageFill` — reveals a supplied `UIImage` through the skeleton's lines, points and labels
  - `font` — custom `UIFont` for measurement labels
  - `letterSpacing` — label letter spacing in ems
- Front Pushups fitness exercise
- Styling Demo sample app — live menu for every overlay style option

### Changed
- Overlay lines now use round caps and joins by default (previously butt caps). Set `lineCap: .butt` to restore the previous look.

## v1.2.14 - 2026-04-20

### Added
- Public `QuickPose.latestCameraImage: UIImage?` — latest camera frame at native orientation (front camera not mirrored).
- Public `QuickPose.latestIsFrontCamera: Bool` — current camera position.

Enables on-demand camera+overlay composites from an external renderer without forcing `.overlayHasCameraAsBackground` into the live pipeline.

## v1.2.13 - 2025-09-29
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

