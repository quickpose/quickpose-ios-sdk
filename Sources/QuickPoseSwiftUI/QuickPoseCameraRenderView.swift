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
    
    public  func updateUIView(_ uiView: CameraRenderUIView, context: Context) {
        
    }
}
