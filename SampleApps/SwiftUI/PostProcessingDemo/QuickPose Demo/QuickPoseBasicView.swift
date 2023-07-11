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
    
    @State private var overlayImage: UIImage?
    @State private var filename: String? = nil
    @State private var fileProcessingProgress: Int? = nil
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                if let filename = filename {
                    Text("Processing\n\(filename)").multilineTextAlignment(.center)
                }
                if let progress = fileProcessingProgress {
                    Text("\(progress)%").padding(.top, 20)
                }
            }
            .font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
            .edgesIgnoringSafeArea(.all)
            .onAppear() {
                DispatchQueue.global(qos: .userInteractive).async {
                    let quickPosePP = QuickPosePostProcessor(sdkKey: "YOUR SDK KEY HERE") // register for your free key at https://dev.quickpose.ai
                    
                    let request = QuickPosePostProcessor.Request(input: Bundle.main.url(forResource: "tennis_240fps.mov", withExtension: nil)!, output: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("tennis_240fps.mov"), outputType: .mov)
                    
                    fileProcessingProgress = nil
                    filename = request.input.lastPathComponent
                    
                    print("Processing \(request.input.lastPathComponent) -> \(request.output)")
                    do {
                        let features: [QuickPose.Feature] = [.rangeOfMotion(.shoulder(side: .right, clockwiseDirection: true), style: QuickPose.Style(relativeFontSize: 0.5, relativeArcSize: 0.5, relativeLineWidth: 0.5))]
                        
                        
                        try quickPosePP.process(features: features, isFrontCamera: true, request: request) { progress, time, _, _, features, _, _ in
                            fileProcessingProgress = Int(progress * 100)
                            if let feature = features.first {
                                print("\(time), \(feature.key.displayString) \(feature.value.stringValue)")
                            } else {
                                print("\(time)")
                            }
                            // quickPosePP.update(features: [QuickPose.Feature]) // you can update the features based on the video, like in real time.
                            
                        }
                        fileProcessingProgress = 100
                    } catch {
                        print("\(request.input.lastPathComponent): file could not be processed: \(error)")
                    }
                }
            }
        }
    }
}

