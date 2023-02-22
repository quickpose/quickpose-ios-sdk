//
//  QuickPose_BasicDemoApp.swift
//  QuickPose Demo
//
//  Created by QuickPose.ai on 12/12/2022.
//

import SwiftUI
import QuickPoseCore
import QuickPoseSwiftUI

struct QuickPoseBasicView: View {

    private var quickPose = QuickPose(sdkKey: "01GS5J4JEQQZDZZB0EYSE974BV")
    @State private var overlayImage: UIImage?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                if ProcessInfo.processInfo.isiOSAppOnMac, let url = Bundle.main.url(forResource: "happy-dance", withExtension: "mov") {
                    QuickPoseSimulatedCameraView(useFrontCamera: true, delegate: quickPose, video: url)
                } else {
                    QuickPoseCameraView(useFrontCamera: true, delegate: quickPose)
                }
                QuickPoseOverlayView(overlayImage: $overlayImage)
            }
            .overlay(alignment: .bottom) {
                Text("Powered by QuickPose.ai v\(quickPose.quickPoseVersion())") // remove logo here, but attribution appreciated
                    .font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                    .frame(maxHeight:  40 + geometry.safeAreaInsets.bottom, alignment: .center)
                    .padding(.bottom, 0)
            }
            .frame(width: geometry.size.width)
            .edgesIgnoringSafeArea(.all)
            
            .onAppear {
                quickPose.start(features: [.rangeOfMotion(.shoulder(side: .left, clockwiseDirection: false))], onFrame: { status, image, features, landmarks in
                    if case .success(_) = status {
                        overlayImage = image
                    }
                })
            }.onDisappear {
                quickPose.stop()
            }
            
        }
    }
}

