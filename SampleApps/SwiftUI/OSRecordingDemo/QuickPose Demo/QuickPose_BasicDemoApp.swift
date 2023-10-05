//
//  QuickPose_BasicDemoApp.swift
//  QuickPose Demo
//
//  Created by QuickPose.ai on 12/12/2022.
//

import SwiftUI
import AVFoundation
import ReplayKit

@main
struct QuickPose_DemoApp: App {
    var body: some Scene {
        WindowGroup {
            DemoAppView()
                .edgesIgnoringSafeArea(.all)
                .background(Color("AccentColor"))
        }
    }
}

struct DemoAppView: View {
    @State var cameraPermissionGranted = false
    var body: some View {
        GeometryReader { geometry in
            if cameraPermissionGranted {
                QuickPoseRecordingView()
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

struct QuickPoseRecordingView: View {
    @State var readyToPlay = false
    @State var outputURLData: URL? = nil
    @State var isRecording = true
    
    var body: some View {
        GeometryReader { geometry in
            if readyToPlay {
                QuickPoseBasicView()
                    .overlay(alignment: .topTrailing) {
                        Button(action: {
                            readyToPlay = false
                            if isRecording {
                                let fileURL: URL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("screenRecording-\(UUID().uuidString).mp4")
                                RPScreenRecorder.shared().stopRecording(withOutput: fileURL) { error in
                                    if let error = error {
                                        print(error)
                                    } else {
                                        self.outputURLData = fileURL
                                    }
                                }
                            }
                            
                        }) {
                            Image(systemName: "xmark.circle").foregroundColor(Color.white).imageScale(.large).padding(50)
                        }
                    }
            } else {
                VStack(alignment: .center, spacing: 32) {
                    
                    Text("Welcome").font(.headline)
                    
                    Text("This demo app draws an overlay over your body's joints").font(.body)
                    
                    Toggle(isOn: $isRecording ) {
                        Text("Record Session").font(.body)
                    }
                    .toggleStyle(.switch)
                    
                    Button(action:{
                        self.readyToPlay = true
                        if isRecording {
                            RPScreenRecorder.shared().startRecording() { error in
                                if let error  = error {
                                    print(error)
                                    isRecording = false
                                }
                            }
                        }
                    }){
                        Text("Start").font(.headline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .frame(width: geometry.size.width-64)
                            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.white, lineWidth: 1))
                    }
                    
                    
                }
                .foregroundColor(Color.white)
                .frame(width: geometry.size.width-64, height: geometry.size.height)
                .padding(.horizontal, 32)
                
            }
        }.background(EmptyView().fullScreenCover(item: $outputURLData) { content in
            ActivityViewController(activityItems: [content], applicationActivities: nil)
        })
    }
}

extension URL: Identifiable {
    public var id: URL { self }
}

struct ActivityViewController: UIViewControllerRepresentable {
    
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        controller.excludedActivityTypes = [
            .assignToContact]
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}
    
}
