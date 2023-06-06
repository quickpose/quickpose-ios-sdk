//
//  File.swift
//  
//
//  Created by Peter Nash on 17/01/2023.
//

import Foundation
import AVFoundation
import UIKit
import SwiftUI

public struct QuickPoseCameraRenderView: UIViewRepresentable {
    
    public class CameraRenderUIView: UIView {
        public override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }
    
    let view = CameraRenderUIView()
    let session: AVCaptureSession
    let videoGravity: AVLayerVideoGravity
    
    public init(session: AVCaptureSession, videoGravity: AVLayerVideoGravity) {
        self.session = session
        self.videoGravity = videoGravity
    }
    public func makeUIView(context: Context) -> CameraRenderUIView {
        view.backgroundColor = .black
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = videoGravity
        return view
    }
    
    public func updateUIView(_ uiView: CameraRenderUIView, context: Context) {
        if let connection = uiView.videoPreviewLayer.connection, connection.isVideoOrientationSupported, UIDevice.current.orientation.isValidInterfaceOrientation, let videoOrientation = AVCaptureVideoOrientation(rawValue: UIDevice.current.orientation.rawValue), (connection.videoOrientation != videoOrientation || session.connections[0].videoOrientation != videoOrientation) {
            
            connection.videoOrientation = videoOrientation // rotates view
            session.connections[0].videoOrientation = videoOrientation // rotations ml
            print("Updating QuickPose orientation to \(UIDevice.current.orientation.displayString)")
        }
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
