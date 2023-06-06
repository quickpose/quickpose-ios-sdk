//
//  PodsDemoApp.swift
//  PodsDemo
//
//  Created by Peter Nash on 05/06/2023.
//

import SwiftUI
import AVFoundation

@main
struct QuickPose_DemoApp: App {
    var body: some Scene {
        WindowGroup {
            DemoAppView().edgesIgnoringSafeArea(.all)
                .background(Color("AccentColor"))
        }
    }
}

struct DemoAppView: View {
    @State var cameraPermissionGranted = false
    var body: some View {
        GeometryReader { geometry in
            if cameraPermissionGranted {
                QuickPoseBasicView()
            }
        }.onAppear {
            AVCaptureDevice.requestAccess(for: .video) { accessGranted in
                DispatchQueue.main.async {
                    self.cameraPermissionGranted = accessGranted
                }
            }
        }
    }
}
