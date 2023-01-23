//
//  QuickPose_DemoApp.swift
//  QuickPose Demo
//
//  Created by Peter Nash on 12/12/2022.
//

import SwiftUI
import AVFoundation

@main
struct QuickPose_DemoApp: App {
    var body: some Scene {
        WindowGroup {
            GeometryReader { fullScreenGeometry in
                DemoAppView().edgesIgnoringSafeArea(.all)
                    .environment(\.geometry, fullScreenGeometry.size)
                    .environment(\.safeAreaInsets, fullScreenGeometry.safeAreaInsets)
                    .background(Color("AccentColor"))
            }
        }
    }
}

struct DemoAppView: View {
    @State var cameraPermissionGranted = false
    var body: some View {
        GeometryReader { geometry in
            if cameraPermissionGranted {
                QuickPosePickerView()
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


extension EnvironmentValues {
    private struct GeometryEnvironmentKey: EnvironmentKey {
        static let defaultValue: CGSize = CGSize(width: 0, height: 0)
    }
    private struct SafeAreaInsetEnvironmentKey: EnvironmentKey {
        static let defaultValue: EdgeInsets = EdgeInsets()
        
    }
    var geometry: CGSize {
        get { self[GeometryEnvironmentKey.self] }
        set { self[GeometryEnvironmentKey.self] = newValue }
    }
    var safeAreaInsets: EdgeInsets {
        get { self[SafeAreaInsetEnvironmentKey.self] }
        set { self[SafeAreaInsetEnvironmentKey.self] = newValue }
    }
}


