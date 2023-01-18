////
////  File.swift
////  
////
////  Created by Peter Nash on 12/01/2023.
////
//
//import Foundation
//import SwiftUI
//import AVFoundation
//
//public class QuickPoseCamera {
//    
//    public var session: AVCaptureSession? = nil
//    
//    private let useFrontCamera: Bool
//    private var device: AVCaptureDevice? = nil
//    private lazy var output: AVCaptureVideoDataOutput = .init()
//    private let qpProcessingQueue = DispatchQueue(label: "QPProcessingQueue", qos: .userInteractive)
//    
//    init(useFrontCamera: Bool) {
//        self.useFrontCamera = useFrontCamera
//    }
//    
//    func start(delegate: AVCaptureVideoDataOutputSampleBufferDelegate?) throws {
//        device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position:  useFrontCamera ? .front : .back)
//        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String : kCVPixelFormatType_32BGRA]
//        if let device = device {
//            let session = AVCaptureSession()
//            let input: AVCaptureDeviceInput = try AVCaptureDeviceInput(device: device)
//            session.addInput(input)
//            session.addOutput(output)
//            session.connections[0].videoOrientation = .portrait
//            // deliberately keeping front camera not mirrored to keep ML data points consistent
//            
//            self.session = session
//            
//            output.setSampleBufferDelegate(delegate, queue: qpProcessingQueue)
//            qpProcessingQueue.async {
//                session.startRunning()
//            }
//        }
//    }
//    
//    func stop(){
//        if let cameraFeedSession = self.session {
//            
//            cameraFeedSession.stopRunning()
//            
//            for input in cameraFeedSession.inputs {
//                cameraFeedSession.removeInput(input)
//            }
//            for output in cameraFeedSession.outputs {
//                cameraFeedSession.removeOutput(output)
//            }
//            self.session = nil
//        }
//        device = nil
//        output.setSampleBufferDelegate(nil, queue: qpProcessingQueue)
//        output = .init()
//    }
//}
//
//
//public struct QuickPoseCameraRenderView: UIViewRepresentable {
//    
//    public class CameraRenderUIView: UIView {
//        public override class var layerClass: AnyClass {
//            AVCaptureVideoPreviewLayer.self
//        }
//        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
//            return layer as! AVCaptureVideoPreviewLayer
//        }
//    }
//    
//    public let view = CameraRenderUIView()
//    let session: AVCaptureSession
//    let videoGravity: AVLayerVideoGravity
//    
//    public func makeUIView(context: Context) -> CameraRenderUIView {
//        view.backgroundColor = .black
//        view.videoPreviewLayer.session = session
//        view.videoPreviewLayer.videoGravity = videoGravity
//        return view
//    }
//    
//    public  func updateUIView(_ uiView: CameraRenderUIView, context: Context) {
//        
//    }
//}
