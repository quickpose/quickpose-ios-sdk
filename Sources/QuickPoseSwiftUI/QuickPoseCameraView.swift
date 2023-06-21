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
    
    let frameRate: Binding<Double?>?
    @State var cameraReady: Bool = false
    @State var camera: QuickPoseCamera? = nil
    
    public init(useFrontCamera: Bool, delegate: AVCaptureVideoDataOutputSampleBufferDelegate, frameRate: Binding<Double?>? = nil, videoGravity: AVLayerVideoGravity = .resizeAspectFill) {
        self.camera = QuickPoseCamera(useFrontCamera: useFrontCamera)
        self.delegate = delegate
        self.videoGravity = videoGravity
        self.frameRate = frameRate
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            if cameraReady, let cameraFeedSession = camera?.session {
                QuickPoseCameraRenderView(session: cameraFeedSession, videoGravity: videoGravity)
            }
        }.onAppear {
            do {
                try camera?.start(delegate: delegate, frameRate: frameRate?.wrappedValue)
                cameraReady = true
                
            } catch let error {
                print(error)
            }
        }.onDisappear(){
            camera?.stop()
        }.onChange(of: frameRate?.wrappedValue){ newFrameRate in
            cameraReady = false
            camera?.setFrameRate(newFrameRate)
            
            cameraReady = true
        }
    }
}
