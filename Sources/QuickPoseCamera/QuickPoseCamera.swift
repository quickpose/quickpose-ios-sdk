//
//  File.swift
//
//
//  Created by Peter Nash on 12/01/2023.
//

import Foundation
import AVFoundation

/// QuickPose provides developer-oriented cutting edge ML features with easy integration and production ready code.
///
/// Use QuickPose when you want to process a camera's output frame and perform a common ML feature to the image,
/// such as overlaying markings to the output image to highlight the user.
///
///       +----------+          +-------------+          +-------------+
///       |          |          |             |          |    Image    |
///       |  Camera  |--------->|  QuickPose  |--------->|      +      |
///       |          |          |             |          |   Results   |
///       +----------+          +-------------+          +-------------+
///
/// For performance and developer-centricity reasons QuickPose does not render the camera's output
/// or display the output annotations itself, for SwiftUI it uses a ``QuickPoseCameraView`` and ``QuickPoseOverlayView``.
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


