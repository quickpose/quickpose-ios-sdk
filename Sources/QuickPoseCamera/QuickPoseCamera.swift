//
//  File.swift
//
//
//  Created by QuickPose.ai on 12/01/2023.
//

import Foundation
import AVFoundation

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
    
    public init(useFrontCamera: Bool) {
        self.useFrontCamera = useFrontCamera
    }
    
    public func start(delegate: AVCaptureVideoDataOutputSampleBufferDelegate?) throws {
        device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position:  useFrontCamera ? .front : .back)
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String : kCVPixelFormatType_32BGRA]
        if let device = device {
            let session = AVCaptureSession()
            let input: AVCaptureDeviceInput = try AVCaptureDeviceInput(device: device)
            session.addInput(input)
            session.addOutput(output)
            session.connections[0].videoOrientation = .portrait
            
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
}


