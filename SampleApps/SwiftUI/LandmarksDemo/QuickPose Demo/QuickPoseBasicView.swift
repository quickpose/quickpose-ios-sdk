//
//  QuickPose_BasicDemoApp.swift
//  QuickPose Demo
//
//  Created by QuickPose.ai on 12/12/2022.
//

import SwiftUI
import QuickPoseCore
import QuickPoseSwiftUI
import AVFoundation

struct QuickPoseBasicView: View {

    private var quickPose = QuickPose(sdkKey: "YOUR SDK KEY HERE") // register for your free key at https://dev.quickpose.ai
    @State private var overlayImage: UIImage?
    @State private var scaledToViewPoint = CGPoint(x: 1080/2, y: 1920/2)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                if true, let url = Bundle.main.url(forResource: "happy-dance", withExtension: "mov") {
                    QuickPoseSimulatedCameraView(useFrontCamera: true, delegate: quickPose, video: url, videoGravity: .resizeAspect)
                } else {
                    QuickPoseCameraView(useFrontCamera: true, delegate: quickPose, videoGravity: .resizeAspect)
                }
                QuickPoseOverlayView(overlayImage: $overlayImage, contentMode: .fit)
            }
            .overlay(alignment: .topLeading) {
                Circle()
                    .position(x: scaledToViewPoint.x, y: scaledToViewPoint.y)
                    .frame(width: 12, height: 12)
                    .foregroundColor(Color.green.opacity(1.0))
                
            }
            .frame(width: geometry.size.width)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                quickPose.start(features: [.showPoints()], onFrame: { status, image, features, feedback, landmarks in
                    overlayImage = image
                    if case .success(_, _) = status, let landmarks = landmarks {
                        
                        let bodyNose = landmarks.landmark(forBody: .nose)
                        let bodyNoseWorld = landmarks.worldLandmark(forBody: .nose)

                        scaledToViewPoint = bodyNose.cgPoint(scaledTo: geometry.size, flippedHorizontally: landmarks.isFrontCamera)
  
                        if let nose = landmarks.landmark(forFace: .faceNose) {
                            print(nose.cgPoint(scaledTo: geometry.size, flippedHorizontally: landmarks.isFrontCamera))
                            print(nose)
                        }
                    } else {
                        // show error feedback
                    }
                })
            }.onDisappear {
                quickPose.stop()
            }
            .overlay(alignment: .bottom) {
                Text("Powered by QuickPose.ai v\(quickPose.quickPoseVersion())") // remove logo here, but attribution appreciated
                    .font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                    .frame(maxHeight:  40 + geometry.safeAreaInsets.bottom, alignment: .center)
                    .padding(.bottom, 0)
            }
            
        }
    }
}

