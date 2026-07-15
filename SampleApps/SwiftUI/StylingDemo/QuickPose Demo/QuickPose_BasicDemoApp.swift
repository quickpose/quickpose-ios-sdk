//
//  QuickPose_BasicDemoApp.swift
//  QuickPose Styling Demo
//
//  Created by QuickPose.ai on 12/12/2022.
//

import SwiftUI
import AVFoundation

@main
struct QuickPose_DemoApp: App {
    var body: some Scene {
        WindowGroup {
            #if !targetEnvironment(simulator)
            GeometryReader { fullScreenGeometry in
                DemoAppView()
                    .environment(\.geometry, fullScreenGeometry.size)
                    .environment(\.safeAreaInsets, fullScreenGeometry.safeAreaInsets)
                    .background(Color("AccentColor"))
            }
            #else
            Text("QuickPose.ai requires a native arm64 device to run")
                .font(.system(size: 42, weight: .semibold)).foregroundColor(.red)
            #endif
        }
    }
}

struct DemoAppView: View {
    @State var cameraPermissionGranted = !ProcessInfo.processInfo.isiOSAppOnMac
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
