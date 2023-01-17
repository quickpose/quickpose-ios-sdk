//
//  QuickPose_BasicDemoApp.swift
//  QuickPose Demo
//
//  Created by QuickPose.ai on 12/12/2022.
//

import Foundation
import SwiftUI
import AVFoundation
import QuickPoseCore
import QuickPoseSwiftUI

struct QuickPoseBasicView: View {
    @Environment(\.geometry) private var geometrySize
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    
    private var quickPose = QuickPose()
    @State private var overlayImage: UIImage?
    
    var body: some View {
        ZStack(alignment: .top) {
            QuickPoseCameraView(useFrontCamera: true, delegate: quickPose)
            QuickPoseOverlayView(overlayImage: $overlayImage)
        }
        .overlay(alignment: .bottom) {
            Text("Powered by QuickPose.ai") // remove logo here, but attribution appreciated
                .font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                .frame(maxHeight:  32 + safeAreaInsets.bottom, alignment: .center)
                .padding(.bottom, 0)
        }
        .onAppear {
            quickPose.start(features: [.overlay(.userLeftArm)], onFrame: { status, image, features, landmarks in
                if case .success(_) = status {
                    overlayImage = image
                }
            })
        }.onDisappear {
            quickPose.stop()
        }
        .frame(width: geometrySize.width)
        .edgesIgnoringSafeArea(.all)
    }
}

