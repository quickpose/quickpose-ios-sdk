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

public struct QuickPoseCameraSwitchView: View {

    let useFrontCamera: Binding<Bool>
    let delegate: AVCaptureVideoDataOutputSampleBufferDelegate
    let frameRate: Binding<Double?>?
    @State var cameraReady: Bool = false
    @State var frontCamera = QuickPoseCamera(useFrontCamera: true)
    @State var rearCamera = QuickPoseCamera(useFrontCamera: false)
  
    public init(useFrontCamera: Binding<Bool>, delegate: AVCaptureVideoDataOutputSampleBufferDelegate, frameRate: Binding<Double?>? = nil) {
        self.useFrontCamera = useFrontCamera
        self.delegate = delegate
        self.frameRate = frameRate
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            if cameraReady {
                if let cameraFeedSession = frontCamera.session {
                    QuickPoseCameraRenderView(session: cameraFeedSession, videoGravity: .resizeAspectFill)
                }
                if let cameraFeedSession = rearCamera.session {
                    QuickPoseCameraRenderView(session: cameraFeedSession, videoGravity: .resizeAspectFill)
                }
            }
        }.onAppear {
            do {
                if useFrontCamera.wrappedValue {
                    try frontCamera.start(delegate: delegate, frameRate: frameRate?.wrappedValue)
                } else {
                    try rearCamera.start(delegate: delegate, frameRate: frameRate?.wrappedValue)
                }
                cameraReady = true
                
            } catch let error {
                print(error)
            }
        }.onDisappear(){
            frontCamera.stop()
            rearCamera.stop()
           
        }.onChange(of: useFrontCamera.wrappedValue){ newUseFrontCamera in
            cameraReady = false
            if !newUseFrontCamera {
                frontCamera.stop()
                try! rearCamera.start(delegate: delegate, frameRate: frameRate?.wrappedValue)
            } else {
                rearCamera.stop()
                try! frontCamera.start(delegate: delegate, frameRate: frameRate?.wrappedValue)
            }
            cameraReady = true
        }
        .onChange(of: frameRate?.wrappedValue){ newFrameRate in
            cameraReady = false
            let camera = useFrontCamera.wrappedValue ? frontCamera : rearCamera
            camera.setFrameRate(newFrameRate)
            
            cameraReady = true
        }
    }
}
