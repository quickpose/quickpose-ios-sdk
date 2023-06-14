//
//  QuickPoseSimulatedCameraView.swift
//
//
//  Created by QuickPose.ai on 12/01/2023.
//

import Foundation
import SwiftUI
import AVFoundation
#if QUICKPOSECORE
#else
import QuickPoseCore
import QuickPoseCamera
#endif


public struct QuickPoseSimulatedCameraView: View {

    let delegate: QuickPoseCaptureAVAssetOutputSampleBufferDelegate?
    let videoGravity: AVLayerVideoGravity
    @State var cameraReady: Bool = false
    @State var camera: QuickPoseSimulatedCamera? = nil

    public init(useFrontCamera: Bool, delegate: QuickPoseCaptureAVAssetOutputSampleBufferDelegate?, video: URL,  onVideoLoop: (()->())? = nil, videoGravity: AVLayerVideoGravity = .resizeAspectFill) {
        self.camera = QuickPoseSimulatedCamera(useFrontCamera: useFrontCamera, asset: AVAsset(url: video), onVideoLoop: onVideoLoop)
        self.delegate = delegate
        self.videoGravity = videoGravity
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            if cameraReady, let avAssetPlayer = camera?.player {
                QuickPoseAssetRenderView(player: avAssetPlayer, videoGravity: videoGravity)
            } else {
                EmptyView()
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
