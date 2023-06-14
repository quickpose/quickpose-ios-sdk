//
//  File.swift
//
//
//  Created by Peter Nash on 12/01/2023.
//

import Foundation
import SwiftUI
import AVFoundation
#if QUICKPOSECORE
#else
import QuickPoseCamera
#endif

public struct QuickPoseCameraView: View {

    let delegate: AVCaptureVideoDataOutputSampleBufferDelegate
    let videoGravity: AVLayerVideoGravity
    @State var cameraReady: Bool = false
    @State var camera: QuickPoseCamera? = nil

    public init(useFrontCamera: Bool, delegate: AVCaptureVideoDataOutputSampleBufferDelegate, videoGravity: AVLayerVideoGravity = .resizeAspectFill) {
        self.camera = QuickPoseCamera(useFrontCamera: useFrontCamera)
        self.delegate = delegate
        self.videoGravity = videoGravity
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            if cameraReady, let cameraFeedSession = camera?.session {
                QuickPoseCameraRenderView(session: cameraFeedSession, videoGravity: videoGravity)
            }
        }.onAppear {
            do {
                try camera?.start(delegate: delegate)
                cameraReady = true
                
            } catch let error {
                print(error)
            }
        }.onDisappear(){
            camera?.stop()
        }
    }
}
