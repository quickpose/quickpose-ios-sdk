
import SwiftUI
import QuickPoseCore
import QuickPoseSwiftUI

struct QuickPosePickerView: View {
    @Environment(\.geometry) private var geometrySize
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    private let initialBrightness = UIScreen.main.brightness
    
    @State private var selectedFeature: QuickPose.Feature = .overlay(.wholeBody)
    private var quickPose = QuickPose()
    @State private var overlayImage: UIImage?
    
    @State var useFrontCamera: Bool = true
    
    @State private var lastResult: String? = nil
    @State private var lastFPS: Int = 0
    @State private var showResult: String? = nil
    @State private var cameraViewOpacity: Double = 0
    @State private var captureButtonOpacity: Double = 0
    
    var body: some View {
        ZStack(alignment: .top) {
            QuickPoseCameraSwitchView(useFrontCamera: $useFrontCamera, delegate: quickPose)
            QuickPoseOverlayView(overlayImage: $overlayImage)
        }
        .overlay(alignment: .top) {
            HStack {
                Menu {
                    Picker("", selection: $selectedFeature) {
                        ForEach(QuickPose.Feature.allFeatures(), id: \.self) { feature in
                            Text(feature.displayString())
                        }
                    }
                    .tint(.white)
                    
                    .onChange(of: selectedFeature) { _ in
                        quickPose.update(features: [selectedFeature])
                        
                    }
                } label: {
                    Text(Image(systemName: "arrow.up.and.down.square.fill")) + Text(" Feature: "+selectedFeature.displayString())
                }.font(.system(size: 20, weight: .semibold)).foregroundColor(.white).lineLimit(1)
                    .frame(alignment: .leading)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(RoundedRectangle(cornerRadius: 44/2).foregroundColor(Color("AccentColor").opacity(0.8)))
                
                Spacer()
                
                Button(action: {
                    useFrontCamera.toggle()
                }) {
                    Text(Image(systemName: "arrow.triangle.2.circlepath.camera"))
                        .font(.system(size: 20, weight: .semibold)).foregroundColor(.white)
                        .padding(8)
                        .background(Circle().foregroundColor(Color("AccentColor").opacity(0.8)))
                }.frame(alignment: .trailing)
                
 
            }
            .padding(.top, 24 + safeAreaInsets.top)
            .padding(.horizontal, 16)
            .frame(width: geometrySize.width)
        }
        
        .overlay(alignment: .bottom) {
            Button(action: {
                showResult = lastResult
            }) {
                Text("Capture")
                    .font(.system(size: 24, weight: .semibold)).foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal,16)
                    .frame(width: geometrySize.width - 24*2)
                    .background(RoundedRectangle(cornerRadius: 44).foregroundColor(Color("AccentColor")))
                    .padding(.bottom, 32 + safeAreaInsets.bottom)
            }
            .alert(item: $showResult) { result in
                Alert(title: Text("Result"),
                      message: Text("Your measurement was \(result)"),
                      dismissButton: .default(Text("OK"))
                )
            }.opacity(captureButtonOpacity)
        }
        .overlay(alignment: .bottom) {
            Text("Powered by QuickPose.ai - \(lastFPS) fps") // remove logo here, but attribution appreciated
                .font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                .frame(maxHeight:  32 + safeAreaInsets.bottom, alignment: .center)
                .padding(.bottom, 0)
        }
       
        .onAppear {
                quickPose.start(features: [selectedFeature], onStart: {
                    withAnimation { cameraViewOpacity = 1.0 } // unhide the camera when loaded
                }, onFrame: { status, image, features, landmarks in
                    if case let .success(fps) = status {
                        lastFPS = fps
                        if case let .reading(_, displayString) = features[selectedFeature] {
                            lastResult = displayString
                            if captureButtonOpacity == 0 { // only show button when reading available
                                withAnimation { captureButtonOpacity = 1 }
                            }
                        } else if captureButtonOpacity == 1 {
                            withAnimation { captureButtonOpacity = 0 }
                        }
                        overlayImage = image
                    }
                })
                
                UIApplication.shared.isIdleTimerDisabled = true  // keep screen on when in use
           
        }
        .onDisappear {
            quickPose.stop()
            UIApplication.shared.isIdleTimerDisabled = false
            UIScreen.main.brightness = self.initialBrightness
        }
        .frame(width: geometrySize.width)
        .edgesIgnoringSafeArea(.all)
        .opacity(cameraViewOpacity)
        
    }
}



extension String: Identifiable {
    public typealias ID = Int
    public var id: Int {
        return hash
    }
}

extension QuickPose.Feature{
    public func displayString() -> String {
        switch self {
        case .overlay(let limb):
            return limb.rawValue
        @unknown default:
            fatalError()
        }
    }
    public static func allFeatures() -> [QuickPose.Feature] {
        QuickPose.Landmarks.Group.commonLimbs().map { overlay($0)}
    }
}
