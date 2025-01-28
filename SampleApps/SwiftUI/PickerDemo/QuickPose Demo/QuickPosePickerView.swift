
import SwiftUI
import QuickPoseCore
import QuickPoseCamera
import QuickPoseSwiftUI

struct ValueBar: View {
    var value: Double
    var opacity: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(Color.white)
                    .frame(width: geometry.size.width * CGFloat(value))
                    .opacity(opacity)
            }.cornerRadius(8)
        }.frame(height: 16)
    }
}

extension UIImage {
  func mergeWith(topImage: UIImage) -> UIImage {
    let bottomImage = self

    UIGraphicsBeginImageContext(size)


    let areaSize = CGRect(x: 0, y: 0, width: bottomImage.size.width, height: bottomImage.size.height)
    bottomImage.draw(in: areaSize)

    topImage.draw(in: areaSize, blendMode: .normal, alpha: 1.0)

    let mergedImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return mergedImage
  }
}

struct QuickPoseStatsView: View {
    @Environment(\.geometry) private var geometrySize
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    
    let quickPose: QuickPose
    let showLag = false
    @Binding var lastFPS: Int
    @Binding var lastLag: Double
    
    var body: some View {
        Text("Powered by QuickPose.ai v\(quickPose.quickPoseVersion())\n\(lastFPS) fps" + (showLag ? "lag \(String(format: "%.2f", lastLag))ms" : "")) // remove logo here, but attribution appreciated
            .font(.system(size: 16, weight: .semibold).monospaced()).foregroundColor(.white)
            .frame(height: 40 + safeAreaInsets.bottom, alignment: .center)
            .padding(.bottom, 0)
    }
}


struct QuickPosePickerView: View {
    @Environment(\.geometry) private var geometrySize
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    private let initialBrightness = UIScreen.main.brightness
    static let fastLabel = "Fast (Body Points only)"
    @State private var showDebugString: String = "Off"
    @State private var performance: String = UserDefaults.standard.bool(forKey: "performanceFast") ? QuickPosePickerView.fastLabel : "Normal"
    @State private var targetFPS: Double? = UserDefaults.standard.bool(forKey: "performanceFast") ? 60 : nil
    
    @State private var lastDebugResult: QuickPoseCore.QuickPose.FeatureResult? = nil
    
    @State private var selectedFeatures: [QuickPose.Feature] = [.overlay(.wholeBody)]
    @State private var selectedComponent: String = QuickPose.Feature.allDemoFeatureComponents().first!
    @State var counter = QuickPoseThresholdCounter()
    @State var timer = QuickPoseThresholdTimer()
    
    private var quickPose = QuickPose(sdkKey: "YOUR SDK KEY HERE") // register for your free key at https://dev.quickpose.ai
    @State private var overlayImage: UIImage?
    
    @State var useFrontCamera: Bool = true
    
    @State private var lastResult: String? = nil
    @State private var lastResultImage: UIImage? = nil
    @State private var lastFPS: Int = 0
    @State private var lastLag: Double = 0
    @State private var showResult: String? = nil
    @State private var cameraViewOpacity: Double = 0
    @State private var captureButtonOpacity: Double = 0
    @State private var counterVisibility: Double = 0
    @State private var timerVisibility: Double = 0
    @State private var customUserHeight: Double = 100
    @State private var count: Int = 0
    @State private var measure: Double = 0
    @State private var timeInPosition: String = ""
    @State private var heightInCMText: String = ""
    @State private var feedbackText: String? = nil
    @State private var showHeightAlert: Bool = false
    @State private var resultsImage: UIImage? = nil
   
    var body: some View {
        ZStack(alignment: .top) {
            if ProcessInfo.processInfo.isiOSAppOnMac, let url = Bundle.main.url(forResource: "rain-dance", withExtension: "mov") {
                QuickPoseSimulatedCameraView(useFrontCamera: false, delegate: quickPose, video: url)
            } else {
                QuickPoseCameraSwitchView(useFrontCamera: $useFrontCamera, delegate: quickPose, frameRate: $targetFPS)
            }
            QuickPoseOverlayView(overlayImage: $overlayImage)
        }
        .overlay(alignment: .top) {
            HStack {
                Menu {
                    
                    Menu {
                        Picker("General", selection: $selectedFeatures) {
                            ForEach(QuickPose.Feature.allDemoFeatures(component: "General"), id: \.self) { feature in
                                Text(feature.first?.displayString ?? "")
                            }
                        }
                        .tint(.white)
                    } label: {
                        Text("General")
                    }
                    Menu {
                        Picker("Input", selection: $selectedFeatures) {
                            ForEach(QuickPose.Feature.allDemoFeatures(component: "Input"), id: \.self) { feature in
                                Text(feature.first?.displayString ?? "")
                            }
                        }
                        .tint(.white)
                    } label: {
                        Text("Input")
                    }
                    Menu {
                        Picker("Fitness", selection: $selectedFeatures) {
                            ForEach(QuickPose.Feature.allDemoFeatures(component: "Fitness"), id: \.self) { feature in
                                Text(feature.first?.displayString ?? "")
                            }
                        }
                        .tint(.white)
                    } label: {
                        Text("Fitness")
                    }
                    Menu {
                        Picker("Sports", selection: $selectedFeatures) {
                            ForEach(QuickPose.Feature.allDemoFeatures(component: "Sports"), id: \.self) { feature in
                                Text("Cycling/Rowing")
                            }
                        }
                        .tint(.white)
                    } label: {
                        Text("Sports")
                    }
                    Menu {
                        Picker("Health", selection: $selectedFeatures) {
                            ForEach(QuickPose.Feature.allDemoFeatures(component: "Health"), id: \.self) { feature in
                                Text(feature.first?.displayString ?? "")
                            }
                        }
                        .tint(.white)
                    } label: {
                        Text("Health")
                    }
                    Menu {
                        Picker("Conditional", selection: $selectedFeatures) {
                            ForEach(QuickPose.Feature.allDemoFeatures(component: "Conditional"), id: \.self) { feature in
                                Text(feature.first?.displayString ?? "")
                            }
                        }
                        .tint(.white)
                    } label: {
                        Text("Conditional")
                    }
                    Menu {
                        Picker("Performance", selection: $performance) {
                            ForEach([QuickPosePickerView.fastLabel, "Normal"], id: \.self) { feature in
                                Text(feature)
                            }
                        }
                        .onChange(of: performance) { _ in
                            // changing model complexity requires restart of quickpose, but tracking can be changed per frame
                            quickPose.update(features: selectedFeatures, modelConfig: performance == "Normal" ? QuickPose.ModelConfig() : QuickPose.ModelConfig(detailedFaceTracking: false, detailedHandTracking: false))
                            UserDefaults.standard.set(performance == QuickPosePickerView.fastLabel , forKey: "performanceFast")
                            targetFPS = performance == QuickPosePickerView.fastLabel ? 60 : nil
                        }
                        .tint(.white)
                    } label: {
                        Text("Performance")
                    }
                    
                    Menu {
                        Picker("Measurement", selection: $selectedFeatures) {
                            ForEach(QuickPose.Feature.allDemoFeatures(component: "Measurement"), id: \.self) { feature in
                                Text(feature.first?.displayString ?? "")
                            }
                        }
                        .tint(.white)
                    } label: {
                        Text("Measurement")
                    }
                    
                    Menu {
                        Picker("Debug", selection: $showDebugString) {
                            ForEach(["On","Off"], id: \.self) { feature in
                                Text(feature)
                            }
                        }
                        .tint(.white)
                    } label: {
                        Text("Debug")
                    }
                   
                
                    .onChange(of: selectedFeatures) { _ in
                        
                        counter.reset()
                        counterVisibility = 0
                        timerVisibility = 0
                        showHeightAlert = false
                        if case let .measureLineBody(_, _, customHeight, _, _) = selectedFeatures.first, customHeight != nil {
                            showHeightAlert = true
                        } else {
                            quickPose.update(features: selectedFeatures)
                        }
                       
                    }
                } label: {
                    Text(Image(systemName: "arrow.up.and.down.square.fill")) + Text(" Feature: "+(selectedFeatures.first?.displayString ?? ""))
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
        .alert("Add Height", isPresented: $showHeightAlert)
        {
            TextField("Your height in CM, e.g. 150", text: $heightInCMText).keyboardType(.numberPad)
            Button("OK"){
                selectedFeatures = [.measureLineBody(p1: .shoulder(side: .left), p2: .shoulder(side: .right), userHeight: Double(heightInCMText) ?? 100, format: "%.fcm")]
                quickPose.update(features: selectedFeatures)
            }
        } message: {
            Text("To show a ruler in CM, please enter your height in CM. ")
        }
        .overlay(alignment: .bottom) {
            if let resultsImage =  resultsImage {
                Image(uiImage: resultsImage).resizable().aspectRatio(contentMode:  .fill)
                    .frame(width: geometrySize.width, height: geometrySize.height)
            }
        }
        .overlay(alignment: .bottom) {
            
            Button(action: {
                showResult = lastResult
                resultsImage = lastResultImage!.mergeWith(topImage: overlayImage!)
            }) {
                Text("Capture")
                    .font(.system(size: 24, weight: .semibold)).foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal,16)
                    .frame(width: geometrySize.width - 24*2)
                    .background(RoundedRectangle(cornerRadius: 44).foregroundColor(Color("AccentColor")))
                    .padding(.bottom, 40 + safeAreaInsets.bottom)
            }
            .alert(item: $showResult) { result in
                Alert(title: Text("Result"),
                      message: Text("Your measurement was \(result)"),
                      dismissButton: .default(Text("OK"))
                )
            }.opacity(captureButtonOpacity)
        }
        .overlay(alignment: .bottom) {
            QuickPoseStatsView(quickPose: quickPose, lastFPS: $lastFPS, lastLag: $lastLag)
        }
        .overlay(alignment: .bottom) {
            if let feature = selectedFeatures.first {
                Text("\(feature.displayString): \(count)")
                    .font(.system(size: 32, weight: .semibold)).foregroundColor(.white)
                    .padding(.bottom, 40 + safeAreaInsets.bottom).opacity(counterVisibility)
                ValueBar(value: measure, opacity:counterVisibility)
            }
        }
        .overlay(alignment: .center) {
            if let feedbackText = feedbackText {
                Text(feedbackText)
                    .font(.system(size: 26, weight: .semibold)).foregroundColor(.white).multilineTextAlignment(.center)
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 8).foregroundColor(Color("AccentColor").opacity(0.8)))
                    .padding(.bottom, 40 + safeAreaInsets.bottom)
                    
            }
        }
        .overlay(alignment: .bottom) {
            if let feature = selectedFeatures.first {
                Text("\(feature.displayString): " + timeInPosition)
                    .font(.system(size: 32, weight: .semibold)).foregroundColor(.white)
                    .padding(.bottom, 40 + safeAreaInsets.bottom).opacity(timerVisibility)
                ValueBar(value: measure, opacity: timerVisibility)
            }
        }
        .overlay(alignment: .bottom) { // showDebug
            if let result = self.lastDebugResult, showDebugString == "On" {
                Text("\(result.stringValue) \(String(format: "%.2f", result.value))")
                    .font(.system(size: 32, weight: .semibold)).foregroundColor(.white)
                    .padding(.bottom, 40*2 + safeAreaInsets.bottom)
            }
        }
        
        .onAppear {
            quickPose.start(features: selectedFeatures, modelConfig: performance == "Normal" ? QuickPose.ModelConfig() : QuickPose.ModelConfig(detailedFaceTracking: false, detailedHandTracking: false), onStart: {
                withAnimation { cameraViewOpacity = 1.0 } // unhide the camera when loaded
            }, onFrame: { status, image, features, feedback, landmarks in
                overlayImage = image
                if case let .success(performance) = status {
                    lastFPS = performance.fps
                    lastLag = performance.latency*1000
                    self.lastDebugResult = nil

                    if let landmarks {
                        print(landmarks.allLandmarksForBody()[0])
                    }
                    
                    if case .rangeOfMotion = selectedFeatures.first, let result = features[selectedFeatures.first!] {
                        lastResult = result.stringValue
//                        lastResultImage = cameraImage
                        if captureButtonOpacity == 0 { // only show button when reading available
                            withAnimation { captureButtonOpacity = 1 }
                        }
                    } else if captureButtonOpacity == 1 {
                        withAnimation { captureButtonOpacity = 0 }
                    }
                    if let feedback = feedback[selectedFeatures.first!]  {
                        feedbackText = feedback.displayString
                    } else {
                        feedbackText = nil
                    }
                    if case .fitness = selectedFeatures.first, let result = features[selectedFeatures.first!]  {
                        measure = result.value
                        if (result.stringValue == "plank") {
                            // no counter for this exercises
                            _ = timer.time(result.value)
                            timeInPosition = String(format: "%.2f", timer.state.time)
                            timerVisibility = 1
                        } else {
                            _ = counter.count(result.value)
                            count = counter.state.count
                            counterVisibility = 1
                        }
                    } else if case .raisedFingers = selectedFeatures.first, let result = features[selectedFeatures.first!] {
                        count = Int(result.value)
                        counterVisibility = 1
                    } else if case .thumbsUp = selectedFeatures.first, let result = features[selectedFeatures.first!] {
                        count = Int(result.value > 0.7 ? 1 : 0)
                        counterVisibility = 1
                    } else if case .thumbsUpOrDown = selectedFeatures.first, let result = features[selectedFeatures.first!] {
                        count = Int(result.stringValue.lowercased().contains("up") && result.value > 0.7 ? 1 : result.stringValue.lowercased().contains("down") && result.value > 0.7 ? -1 : 0)
                        counterVisibility = 1
                    } else {
                        counterVisibility = 0
                    }

                    
                }
            })
            
            UIApplication.shared.isIdleTimerDisabled = true  // keep screen on when in use
            
        }
        .onDisappear {
            timer.stop()
            quickPose.stop()
            UIApplication.shared.isIdleTimerDisabled = false
            UIScreen.main.brightness = self.initialBrightness
        }
        .frame(width: geometrySize.width + safeAreaInsets.leading + safeAreaInsets.trailing)
        .edgesIgnoringSafeArea(.all)
        .opacity(cameraViewOpacity)
        .background(Color.black)
        
    }
}

extension String: Identifiable {
    public typealias ID = Int
    public var id: Int {
        return hash
    }
}

extension QuickPose.Feature {
    public static func allDemoFeatures(component: String) -> [[QuickPose.Feature]] {
        if component == "Measurement" {
            return [
                [.measureLineBody(p1: .shoulder(side: .left), p2: .shoulder(side: .right), userHeight: nil, format: nil)],
                [.measureLineBody(p1: .shoulder(side: .left), p2: .shoulder(side: .right), userHeight: 100, format: "%.fcm")],
                ]
        } else if component == "Health" {
            return [[.rangeOfMotion(.shoulder(side: .left, clockwiseDirection: false))], [.rangeOfMotion(.shoulder(side: .right, clockwiseDirection: true))],
                    [.rangeOfMotion(.hip(side: .right, clockwiseDirection: true))], [.rangeOfMotion(.knee(side: .right, clockwiseDirection: true))], [.rangeOfMotion(.neck(clockwiseDirection: false))], [.rangeOfMotion(.back(clockwiseDirection: false))]]
        } else if component == "Input" {
            return [[QuickPose.Feature.raisedFingers()], [QuickPose.Feature.thumbsUp()], [QuickPose.Feature.thumbsUpOrDown()]]
        } else if component == "Conditional" {
            let greenStyle = QuickPose.Style(conditionalColors: [QuickPose.Style.ConditionalColor(min: 40, max: nil, color: UIColor.green)])
            let redStyle = QuickPose.Style(conditionalColors: [QuickPose.Style.ConditionalColor(min: 180, max: nil, color: UIColor.red)])
            return [[.rangeOfMotion(.shoulder(side: .left, clockwiseDirection: false), style: greenStyle)], [.rangeOfMotion(.knee(side: .right, clockwiseDirection: true), style: redStyle)]]
        } else if component == "Fitness" {
            return [
                [.fitness(.squats)],
                [.fitness(.pushUps)],
                [.fitness(.jumpingJacks)],
                [.fitness(.sumoSquats)],
                [.fitness(.lunges(side:.left))],
                [.fitness(.lunges(side:.right))],
                [.fitness(.sitUps)],
                [.fitness(.cobraWings)],
                [.fitness(.plank)],
                [.fitness(.bicepCurls)],
                [.fitness(.lateralRaises)],
                [.fitness(.frontRaises)]
            ]
        } else if component == "Sports" {
            let bikeStyle = QuickPose.Style(relativeFontSize: 0.33, relativeArcSize: 0.4, relativeLineWidth: 0.3)
            let feature1: QuickPose.Feature = .rangeOfMotion(.shoulder(side: .right, clockwiseDirection: false), style: bikeStyle)
            let feature2: QuickPose.Feature = .rangeOfMotion(.elbow(side: .right, clockwiseDirection: false), style: bikeStyle)
            let feature3: QuickPose.Feature = .rangeOfMotion(.hip(side: .right, clockwiseDirection: false), style: bikeStyle)
            let feature4: QuickPose.Feature = .rangeOfMotion(.knee(side: .right, clockwiseDirection: true), style: bikeStyle)
            return [[feature1,  feature2, feature3, feature4]]
        } else {
            return QuickPose.Landmarks.Group.commonLimbs().map { [QuickPose.Feature.overlay($0)] } + [[QuickPose.Feature.showPoints()]]
        }
    }
    
    public static func allDemoFeatureComponents() -> [String] {
        return ["General", "Input", "Fitness", "Health", "Conditional", "Sports", "Measurement"]
    }
}
