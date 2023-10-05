//
//  QuickPose_BasicDemoApp.swift
//  QuickPose Demo
//
//  Created by QuickPose.ai on 12/12/2022.
//

import SwiftUI
import QuickPoseCore
import QuickPoseSwiftUI
import AVKit

struct QuickPoseBasicView: View {

    private var quickPose = QuickPose(sdkKey: "YOUR SDK KEY HERE") // register for your free key at https://dev.quickpose.ai
    @State private var overlayImage: UIImage?
    
    @State var outputURLData: URL? = nil
    @State private var fileURL: URL? = nil
    @State private var assetWriter: AVAssetWriter? = nil
    @State private var pixelBufferWriter: AVAssetWriterInputPixelBufferAdaptor? = nil
    @State private var frameRate: Double? = nil
    
    func startRecording(renderedSize: CGSize, startTime: CMTime){
        
        fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("screenRecording-\(UUID().uuidString).mp4")
        assetWriter = try! AVAssetWriter(outputURL: fileURL!, fileType: .mov)
        
        let options = [kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA,
                  kCVPixelBufferBytesPerRowAlignmentKey: renderedSize.width * 8,
                                 kCVPixelBufferWidthKey: renderedSize.width,
                                kCVPixelBufferHeightKey: renderedSize.height] as [String : Any]
        let assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: [AVVideoCodecKey:AVVideoCodecType.hevc, AVVideoHeightKey: renderedSize.height, AVVideoWidthKey: renderedSize.width])
        assetWriter?.add(assetWriterInput)
        
        pixelBufferWriter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetWriterInput, sourcePixelBufferAttributes: options)
        assetWriter?.startWriting()
        assetWriter?.startSession(atSourceTime: startTime)
    }
    
    private let queue = DispatchQueue(label:"QPVideoWritingQueue", qos: .userInitiated)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                if ProcessInfo.processInfo.isiOSAppOnMac, let url = Bundle.main.url(forResource: "happy-dance", withExtension: "mov") {
                    QuickPoseSimulatedCameraView(useFrontCamera: true, delegate: quickPose, video: url)
                } else {
                    QuickPoseCameraView(useFrontCamera: true, delegate: quickPose, frameRate: $frameRate)
                }
                QuickPoseOverlayView(overlayImage: $overlayImage)
            }
            .overlay(alignment: .topTrailing) {
                Button(action: {
                    queue.async {
                        quickPose.stop()
                        self.assetWriter?.finishWriting {
                            self.outputURLData = fileURL
                        }
                    }
                }) {
                    Image(systemName: "xmark.circle").foregroundColor(Color.white).imageScale(.large).padding(50)
                }
            }
            .frame(width: geometry.size.width)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                quickPose.start(features: [.overlay(.wholeBody), .overlayHasCameraAsBackground(darkenCamera: 0.1)], onFrame: { status, image, features, feedback, landmarks in
                    overlayImage = image
                    if case .success(info: (let fps, _, let size, let timestamp)) = status {
                        if assetWriter == nil {
                            self.startRecording(renderedSize: size, startTime: timestamp)
                        }
                        queue.async {
                            if let overlayImage = overlayImage?.toPixelBuffer(), let videoWithoutARWriterInputs = pixelBufferWriter,  videoWithoutARWriterInputs.assetWriterInput.isReadyForMoreMediaData {
                                videoWithoutARWriterInputs.append(overlayImage, withPresentationTime: timestamp)
                            }
                        }
                        print(fps)
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
            .background(EmptyView().fullScreenCover(item: $outputURLData) { content in
                ActivityViewController(activityItems: [content], applicationActivities: nil)
            })
        }
    }
}

extension UIImage {
    func toPixelBuffer() -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.size.width), Int(self.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
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
