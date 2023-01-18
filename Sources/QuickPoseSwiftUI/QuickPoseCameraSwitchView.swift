//
//  File.swift
//
//
//  Created by Peter Nash on 12/01/2023.
//

import Foundation
import SwiftUI
import AVFoundation
import QuickPoseCamera

public struct QuickPoseCameraSwitchView: View {

    let useFrontCamera: Binding<Bool>
    let delegate: AVCaptureVideoDataOutputSampleBufferDelegate
    
    @State var cameraReady: Bool = false
    @State var frontCamera = QuickPoseCamera(useFrontCamera: true)
    @State var rearCamera = QuickPoseCamera(useFrontCamera: false)
  
    public init(useFrontCamera: Binding<Bool>, delegate: AVCaptureVideoDataOutputSampleBufferDelegate) {
        self.useFrontCamera = useFrontCamera
        self.delegate = delegate
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
                    try frontCamera.start(delegate: delegate)
                } else {
                    try rearCamera.start(delegate: delegate)
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
                try! rearCamera.start(delegate: delegate)
            } else {
                rearCamera.stop()
                try! frontCamera.start(delegate: delegate)
            }
            cameraReady = true
        }
    }
}
