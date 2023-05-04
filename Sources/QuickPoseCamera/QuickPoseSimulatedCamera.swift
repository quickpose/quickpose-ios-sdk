//
//  File.swift
//
//
//  Created by Peter Nash on 12/01/2023.
//

import Foundation
import AVFoundation
import UIKit
import SwiftUI
#if QUICKPOSECORE
#else
import QuickPoseCore
#endif

/// QuickPoseSimulatedCamera prepares an asset reader for a provided avasset and sets a delegate.
///
/// QuickPose itself accepts the video's output frame and perform an ML feature to the image,
/// such as overlaying markings to the output image to highlight the user.
///
///       +----------+          +-------------+          +-------------+
///       |          |          |             |          |    Image    |
///       |  AVAsset |--------->|  QuickPose  |--------->|      +      |
///       |          |          |             |          |   Results   |
///       +----------+          +-------------+          +-------------+
///
/// For performance and developer-centricity reasons QuickPose uses an native asset rendering view ``AVCaptureVideoPreviewLayer`` to show the video output, and a ImageView to display the results.
///
///       +----------+          +-------------+
///       |          |          |             |
///       |  Camera  |--------->|  QuickPose  |
///       |          |          |             |
///       +----------+          +-------------+
///            |                     |
///            |                     |  Overlay, Reading
///           \/                    \/
///       +----------+          +-------------+
///       |          |          |             |
///       |  Camera  |          |   Overlay   |
///       |   View   |          |  ImageView  |
///       |          |          |             |
///       +----------+          +-------------+
///
///
/// For SwiftUI use our provided ``QuickPoseSimulatedCameraView`` , ``QuickPoseCameraView`` and ``QuickPoseOverlayView`` views for setup  (for an example see our demo apps)
///
///     private var quickPose = QuickPose()
///     @State private var overlayImage: UIImage?
///
///     var body: some View {
///         ZStack(alignment: .top) {
///             if ProcessInfo.processInfo.isiOSAppOnMac, let url = Bundle.main.url(forResource: "happy-dance", withExtension: "mov") {
///                 QuickPoseSimulatedCameraView(useFrontCamera: true, delegate: quickPose, video: url)
///             } else {
///                 QuickPoseCameraView(useFrontCamera: true, delegate: quickPose)
///             }
///             QuickPoseOverlayView(overlayImage: $overlayImage)
///         }
///     }
///     
/// For UIKit use setup as following (for an example see our demo apps)
///
///      var camera: QuickPoseCamera?
///      var simulatedCamera: QuickPoseSimulatedCamera?
///      var quickPose = QuickPose()
///
///      @IBOutlet var cameraView: UIView!
///      @IBOutlet var overlayView: UIImageView!
///
///      ....
///
///      if ProcessInfo.processInfo.isiOSAppOnMac, let url = Bundle.main.url(forResource: "happy-dance", withExtension: "mov") {
///              simulatedCamera = QuickPoseSimulatedCamera(useFrontCamera: true, asset: AVAsset(url: url)) // setup simulated camera
///              try? simulatedCamera?.start(delegate: quickPose)
///
///              let customPreviewLayer = AVPlayerLayer(player: simulatedCamera?.player)
///              customPreviewLayer.videoGravity = .resizeAspectFill
///              customPreviewLayer.frame.size = view.frame.size
///              cameraView.layer.addSublayer(customPreviewLayer)
///       } else {
///              camera = QuickPoseCamera(useFrontCamera: true) // setup camera
///              try? camera?.start(delegate: quickPose)
///
///              let customPreviewLayer = AVCaptureVideoPreviewLayer(session: camera!.session!)
///              customPreviewLayer.videoGravity = .resizeAspectFill
///              customPreviewLayer.frame.size = view.frame.size
///              cameraView.layer.addSublayer(customPreviewLayer)
///        }
///
public class QuickPoseSimulatedCamera {
    
    private let useFrontCamera: Bool
    private let asset: AVAsset
    private let videoFileReadingQueue = DispatchQueue(label: "VideoFileReading", qos: .userInteractive)
    
    private var playerItemOutput: AVPlayerItemVideoOutput?
    private var displayLink: CADisplayLink?
    private var videoFileFrameDuration = CMTime.invalid
    
    private weak var delegate: QuickPoseCaptureAVAssetOutputSampleBufferDelegate?
    private var onVideoLoop: (()->())?
    public var player: AVPlayer?
    public var playerItem: AVPlayerItem?
    private var videoFileBufferOrientation = CGImagePropertyOrientation.up
    public init(useFrontCamera: Bool, asset: AVAsset, onVideoLoop: (()->())? = nil) {
        self.useFrontCamera = useFrontCamera
        self.asset = asset
        self.onVideoLoop = onVideoLoop
    }
    
    public func start(delegate: QuickPoseCaptureAVAssetOutputSampleBufferDelegate?) throws {
        self.delegate = delegate
        
        let displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink(_:)))
        displayLink.preferredFramesPerSecond = 0 // Use display's rate
        displayLink.isPaused = true
        displayLink.add(to: RunLoop.current, forMode: .default)
        
        guard let track = asset.tracks(withMediaType: .video).first else {
            print("No video tracks found in AVAsset.")
            return
        }
        
        let playerItem = AVPlayerItem(asset: asset)
        playerItem.videoComposition = AVVideoComposition(propertiesOf: asset)
        let player = AVPlayer(playerItem: playerItem)
        let settings = [
            String(kCVPixelBufferPixelFormatTypeKey): kCVPixelFormatType_32BGRA // this for gpu
        ]
        let output = AVPlayerItemVideoOutput(pixelBufferAttributes: settings)
        let affineTransform = track.preferredTransform.inverted()
        let angleInDegrees = atan2(affineTransform.b, affineTransform.a) * CGFloat(180) / CGFloat.pi
        var orientation: UInt32 = 1
        switch angleInDegrees {
        case 0:
            orientation = 1 // Recording button is on the right
        case 180, -180:
            orientation = 3 // abs(180) degree rotation recording button is on the right
        case 90:
            orientation = 8 // 90 degree CW rotation recording button is on the top
        case -90:
            orientation = 6 // 90 degree CCW rotation recording button is on the bottom
        default:
            orientation = 1
        }
        videoFileBufferOrientation = CGImagePropertyOrientation(rawValue: orientation)!
//        print("native video rotation \(angleInDegrees) degrees")
        playerItem.add(output)
        player.actionAtItemEnd = .pause
        videoFileReadingQueue.async {
            player.play()
        }
        
        self.playerItem = playerItem
        self.player = player
        self.displayLink = displayLink
        self.playerItemOutput = output
        videoFileFrameDuration = track.minFrameDuration
        print(track.nominalFrameRate)
        displayLink.isPaused = false
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(restartVideo),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: self.player?.currentItem)
    }
    @objc func restartVideo() {
        player?.pause()
        player?.currentItem?.seek(to: CMTime.zero) { [weak self] _ in
            self?.onVideoLoop?()
            self?.player?.play()
        }
    }
    
    @objc private func handleDisplayLink(_ displayLink: CADisplayLink) {
        guard let output = playerItemOutput else {
            return
        }
        
        videoFileReadingQueue.async {
            guard let timeStamp = self.playerItem?.currentTime() else {return}
            guard output.hasNewPixelBuffer(forItemTime: timeStamp) else {
                return
            }
            guard let pixelBuffer = output.copyPixelBuffer(forItemTime: timeStamp, itemTimeForDisplay: nil) else {
                return
            }
            let startTime = CMClockGetTime(CMClockGetHostTimeClock()) // use clock time, as video can loop
            self.delegate?.captureAVOutput(didOutput: pixelBuffer, timestamp: startTime, isFrontCamera: self.useFrontCamera)
        }
    }
    
    public func stop(){
        self.displayLink?.invalidate()
        self.displayLink = nil
    }
}

