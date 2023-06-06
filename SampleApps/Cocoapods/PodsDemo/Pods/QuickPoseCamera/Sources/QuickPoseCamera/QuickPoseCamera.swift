//
//  File.swift
//
//
//  Created by QuickPose.ai on 12/01/2023.
//

import Foundation
import AVFoundation
import UIKit // for UIDevice only

/// QuickPose Camera prepares an AVCaptureSession of the device's camera and sets a delegate.
///
/// QuickPose itself accepts the camera's output frame and perform an ML feature to the image,
/// such as overlaying markings to the output image to highlight the user.
///
///       +----------+          +-------------+          +-------------+
///       |          |          |             |          |    Image    |
///       |  Camera  |--------->|  QuickPose  |--------->|      +      |
///       |          |          |             |          |   Results   |
///       +----------+          +-------------+          +-------------+
///
/// For performance and developer-centricity reasons QuickPose uses an native Camera rendering view ``AVCaptureVideoPreviewLayer`` to show the camera output, and a ImageView to display the results.
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
/// For SwiftUI use our provided ``QuickPoseCameraView`` and ``QuickPoseOverlayView`` views for setup  (for an example see our demo apps)
///
///     private var quickPose = QuickPose()
///     @State private var overlayImage: UIImage?
///
///     var body: some View {
///         ZStack(alignment: .top) {
///             QuickPoseCameraView(useFrontCamera: true, delegate: quickPose)
///             QuickPoseOverlayView(overlayImage: $overlayImage)
///         }
///     }
///     
/// For UIKit use setup as following (for an example see our demo apps)
///
///      var camera: QuickPoseCamera?
///      var quickPose = QuickPose()
///
///      @IBOutlet var cameraView: UIView!
///      @IBOutlet var overlayView: UIImageView!
///
///      ....
///
///      // setup camera
///      camera = QuickPoseCamera(useFrontCamera: true)
///      try? camera?.start(delegate: quickPose)
///
///      let customPreviewLayer = AVCaptureVideoPreviewLayer(session: camera!.session!)
///      customPreviewLayer.videoGravity = .resizeAspectFill
///      customPreviewLayer.frame.size = view.frame.size
///      cameraView.layer.addSublayer(customPreviewLayer)
///
///      // setup overlay
///      overlayView.contentMode = .scaleAspectFill // keep overlays in same scale as camera output
///      overlayView.frame.size = view.frame.size
///
public class QuickPoseCamera {
    
    public var session: AVCaptureSession? = nil
    
    private let useFrontCamera: Bool
    private var device: AVCaptureDevice? = nil
    private lazy var output: AVCaptureVideoDataOutput = .init()
    private let qpProcessingQueue = DispatchQueue(label: "QPProcessingQueue", qos: .userInteractive)
    private var initialFrameRate: Int32 = -1
    public init(useFrontCamera: Bool) {
        self.useFrontCamera = useFrontCamera
    }
    
    public func start(delegate: AVCaptureVideoDataOutputSampleBufferDelegate?, frameRate: Double? = nil) throws {
        device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position:  useFrontCamera ? .front : .back)
        
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String : kCVPixelFormatType_32BGRA]
        if let device = device {
            let session = AVCaptureSession()
            let input: AVCaptureDeviceInput = try AVCaptureDeviceInput(device: device)
            session.addInput(input)
            session.addOutput(output)
            initialFrameRate = device.activeVideoMaxFrameDuration.timescale
            device.setFrameRate(frameRate)
            
            if session.connections[0].isVideoOrientationSupported, let videoOrientation = AVCaptureVideoOrientation(rawValue: UIDevice.current.orientation.rawValue) {
                
                if UIDevice.current.orientation.isValidInterfaceOrientation {
                    session.connections[0].videoOrientation = videoOrientation
                    print("Setting QuickPose orientation to \(UIDevice.current.orientation.displayString)")
                } else {
                    session.connections[0].videoOrientation = .portrait // for 'face up' orientations default to portrait.
                    print("Ignoring \(UIDevice.current.orientation.displayString) for QuickPose orientation, setting to portrait")
                }
            }
            // deliberately keeping front camera not mirrored to keep ML data points consistent
            
            self.session = session
            
            output.setSampleBufferDelegate(delegate, queue: qpProcessingQueue)
            qpProcessingQueue.async {
                session.startRunning()
            }
        }
    }
    
    public func stop(){
        if let cameraFeedSession = self.session {
            
            cameraFeedSession.stopRunning()
            
            for input in cameraFeedSession.inputs {
                cameraFeedSession.removeInput(input)
            }
            for output in cameraFeedSession.outputs {
                cameraFeedSession.removeOutput(output)
            }
            self.session = nil
        }
        device = nil
        output.setSampleBufferDelegate(nil, queue: qpProcessingQueue)
        output = .init()
    }
    
    public func setFrameRate(_ frameRate: Double?) {
        qpProcessingQueue.async {
            self.session?.stopRunning()
            self.device?.setFrameRate(frameRate == nil ? Double(self.initialFrameRate) : frameRate)
            self.session?.startRunning()
        }
    }
}

extension AVCaptureDevice {
    fileprivate func setFrameRate(_ frameRate: Double?) {
        
        guard let frameRate = frameRate, activeVideoMaxFrameDuration.timescale != Int32(frameRate) else { return } // if possible avoid changing
        var selectedFormat: AVCaptureDevice.Format? = nil
        let activeDimensions = CMVideoFormatDescriptionGetDimensions(activeFormat.formatDescription);
        for format in formats {
            for range in format.videoSupportedFrameRateRanges {
                let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription);
                if (range.minFrameRate <= frameRate && frameRate <= range.maxFrameRate && dimensions.width == activeDimensions.width && dimensions.height == activeDimensions.height) {
                    selectedFormat = format
                    break
                }
            }
        }
        
        if let selectedFormat = selectedFormat {
            do {
                try lockForConfiguration()
                activeFormat = selectedFormat
                activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: Int32(frameRate))
                activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: Int32(frameRate))
                unlockForConfiguration()
            } catch {
                print("LockForConfiguration failed with error: \(error.localizedDescription)")
            }
        } else {
            print("QuickPose couldn't set frameRate to \(frameRate)fps at \(activeDimensions), continuing with \(String(format:"%.f",activeVideoMaxFrameDuration.timescale))fps")
        }
    }
}

fileprivate extension CMTime {
    var doubleValue: Double {
        return Double(self.value) / Double(self.timescale)
    }
}

fileprivate extension UIDeviceOrientation {
    var displayString: String {
        switch self {
        case .portrait:
            return "Portrait"
        case .portraitUpsideDown:
            return "Portrait Upside Down"
        case .landscapeLeft:
            return "Landscape Left"
        case .landscapeRight:
            return "Landscape Right"
        case .faceUp:
            return "Face Up"
        case .faceDown:
            return "Face Down"
        case .unknown:
            return "Unknown"
        @unknown default:
            return "Unknown"
        }
    }
}
