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
    
    private var quickPose = QuickPose(sdkKey: "01GS5J4JEQQZDZZB0EYSE974BV") // register for your free key at https://dev.quickpose.ai
    @State private var overlayImage: UIImage?
    @State private var feedbackText: String? = nil
    
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
            .overlay(alignment: .center) {
                if let feedbackText = feedbackText {
                    Text(feedbackText)
                        .font(.system(size: 26, weight: .semibold)).foregroundColor(.white).multilineTextAlignment(.center)
                        .padding(16)
                        .background(RoundedRectangle(cornerRadius: 8).foregroundColor(Color("AccentColor").opacity(0.8)))
                        .padding(.bottom, 40)
                }
            }
            .onAppear {
                quickPose.start(features: [.fitness(.frontRaises)], onFrame: { status, image, features, feedback, landmarks in
                    overlayImage = image
                    switch status {
                    case .success:
                        if let result = features.values.first  {
                            feedbackText = "Front Raises: \(Int(result.value * 100))%"
                        } else if let feedback = feedback.values.first, feedback.isRequired  {
                            feedbackText = feedback.displayString
                        } else {
                            feedbackText = nil
                        }
                    case .noPersonFound:
                        feedbackText = "Stand in view";
                    case .sdkValidationError:
                        feedbackText = "Be back soon";
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
            .frame(width: geometry.size.width)
            .edgesIgnoringSafeArea(.all)
        }
    }
}

