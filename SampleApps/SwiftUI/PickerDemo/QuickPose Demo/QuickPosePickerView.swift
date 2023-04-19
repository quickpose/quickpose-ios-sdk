
import SwiftUI
import QuickPoseCore
import QuickPoseCamera
import QuickPoseSwiftUI

struct ValueBar: View {
    // thank you ChatGPT
    var value: Double
    var opacity: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                        .foregroundColor(Color.white)
                        .frame(width: geometry.size.width * CGFloat(value))
                        .opacity(opacity)
            }
                    .cornerRadius(8)
        }
                .frame(height: 16)
    }
}



struct QuickPosePickerView: View {
    @Environment(\.geometry) private var geometrySize
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    private let initialBrightness = UIScreen.main.brightness

    @State private var showDebugString: String = "Off"
    @State private var lastDebugResult: QuickPoseCore.QuickPose.FeatureResult? = nil

    @State private var selectedFeatures: [QuickPose.Feature] = [.overlay(.wholeBody)]
    @State private var selectedComponent: String = QuickPose.Feature.allDemoFeatureComponents().first!
    @State var counter = QuickPoseThresholdCounter()
    @State var measureBasedCounter = MeasureBasedCounter()
    @State var timer = MeasureBasedTimer()

    private var quickPose = QuickPose(sdkKey: "01GS5J4JEQQZDZZB0EYSE974BV")
    @State private var overlayImage: UIImage?

    @State var useFrontCamera: Bool = true

    @State private var lastResult: String? = nil
    @State private var lastFPS: Int = 0
    @State private var showResult: String? = nil
    @State private var cameraViewOpacity: Double = 0
    @State private var captureButtonOpacity: Double = 0
    @State private var counterVisibility: Double = 0
    @State private var timerVisibility: Double = 0
    @State private var isFullBodyVisible: Double = 0

    @State private var count: Int = 0
    @State private var measure: Double = 0
    @State private var timeInPosition: String = ""

    var body: some View {
        ZStack(alignment: .top) {
            if ProcessInfo.processInfo.isiOSAppOnMac, let url = Bundle.main.url(forResource: "rain-dance", withExtension: "mov") {
                QuickPoseSimulatedCameraView(useFrontCamera: true, delegate: quickPose, video: url)
            } else {
                QuickPoseCameraSwitchView(useFrontCamera: $useFrontCamera, delegate: quickPose)
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
                                        quickPose.update(features: selectedFeatures)
                                        counter.reset()
                                        measureBasedCounter.reset()
                                        counterVisibility = 0
                                        timerVisibility = 0
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
                    Text("Powered by QuickPose.ai v\(quickPose.quickPoseVersion()) - \(lastFPS) fps") // remove logo here, but attribution appreciated
                            .font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                            .frame(height: 40 + safeAreaInsets.bottom, alignment: .center)
                            .padding(.bottom, 0)
                }
                .overlay(alignment: .bottom) {
                    if let feature = selectedFeatures.first {
                        Text("\(feature.displayString): \(count)")
                                .font(.system(size: 32, weight: .semibold)).foregroundColor(.white)
                                .padding(.bottom, 40 + safeAreaInsets.bottom).opacity(counterVisibility * isFullBodyVisible)
                        ValueBar(value: measure, opacity: isFullBodyVisible * counterVisibility)
                        Text("Ensure your full body is visible")
                                .font(.system(size: 32, weight: .semibold)).foregroundColor(.red).multilineTextAlignment(.center)
                                .padding(.bottom, 40 + safeAreaInsets.bottom)
                                .opacity((1 - isFullBodyVisible) * counterVisibility)
                    }
                }.overlay(alignment: .bottom) {
                    if let feature = selectedFeatures.first {
                        Text("\(feature.displayString): " + timeInPosition)
                                .font(.system(size: 32, weight: .semibold)).foregroundColor(.white)
                                .padding(.bottom, 40 + safeAreaInsets.bottom).opacity(timerVisibility *  isFullBodyVisible)
                        ValueBar(value: measure, opacity: timerVisibility * isFullBodyVisible)
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
                    quickPose.start(features: selectedFeatures, onStart: {
                        withAnimation { cameraViewOpacity = 1.0 } // unhide the camera when loaded
                    }, onFrame: { status, image, features, landmarks in
                        if case let .success(fps) = status {
                            lastFPS = fps
                            self.lastDebugResult = nil

                            if case .rangeOfMotion = selectedFeatures.first, let result = features[selectedFeatures.first!] {
                                lastResult = result.stringValue
                                if captureButtonOpacity == 0 { // only show button when reading available
                                    withAnimation { captureButtonOpacity = 1 }
                                }
                            } else if captureButtonOpacity == 1 {
                                withAnimation { captureButtonOpacity = 0 }
                            }

                            if let result = features[.checks(.isFullBodyVisible)] {
                                isFullBodyVisible = result.value
                            }

                            if case .fitness = selectedFeatures.first, let result = features[selectedFeatures.first!]  {
                                measure = result.value

                                if (isFullBodyVisible == 1.0) {
                                    if (result.stringValue == "plank") {
                                        // no counter for this exercises
                                        _ = timer.update(measure: result.value)
                                        timeInPosition = String(format: "%.2f", timer.timeInPosition())
                                        timerVisibility = 1
                                    } else {
                                        measureBasedCounter.count(probability: result.value)
                                        count = measureBasedCounter.getCount()
                                        counterVisibility = 1
                                    }
                                }
                            } else if case .raisedFingers = selectedFeatures.first, let result = features[selectedFeatures.first!] {
                                count = Int(result.value)
                                counterVisibility = 1
                            } else if case .thumbsUp = selectedFeatures.first, let result = features[selectedFeatures.first!] {
                                count = Int(result.value > 0.7 ? 1 : 0)
                                counterVisibility = 1
                            } else if case .thumbsUpOrDown = selectedFeatures.first, let result = features[selectedFeatures.first!] {
                                count = Int(result.stringValue == "thumbs_up" && result.value > 0.7 ? 1 : result.stringValue == "thumbs_down" && result.value > 0.7 ? -1 : 0)
                                counterVisibility = 1
                            } else {
                                counterVisibility = 0
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

extension QuickPose.Feature {
    public static func allDemoFeatures(component: String) -> [[QuickPose.Feature]] {

        if component == "Health" {
            return [[.rangeOfMotion(.shoulder(side: .left, clockwiseDirection: false))], [.rangeOfMotion(.shoulder(side: .right, clockwiseDirection: true))],
                    [.rangeOfMotion(.hip(side: .right, clockwiseDirection: true))], [.rangeOfMotion(.knee(side: .right, clockwiseDirection: true))], [.rangeOfMotion(.neck(clockwiseDirection: false)), .rangeOfMotion(.back(clockwiseDirection: false))]]
        } else if component == "Input" {
            return [[QuickPose.Feature.raisedFingers()], [QuickPose.Feature.thumbsUp()], [QuickPose.Feature.thumbsUpOrDown()]]
        } else if component == "Conditional" {
            let greenStyle = QuickPose.Style(conditionalColors: [QuickPose.Style.ConditionalColor(min: 40, max: nil, color: UIColor.green)])
            let redStyle = QuickPose.Style(conditionalColors: [QuickPose.Style.ConditionalColor(min: 180, max: nil, color: UIColor.red)])
            return [[.rangeOfMotion(.shoulder(side: .left, clockwiseDirection: false), style: greenStyle)], [.rangeOfMotion(.knee(side: .right, clockwiseDirection: true), style: redStyle)]]
        } else if component == "Fitness" {
            return [
                [.fitness(.squatCounter), .checks(.isFullBodyVisible)],
                [.fitness(.pushUpCounter), .checks(.isFullBodyVisible)],
                [.fitness(.jumpingJackCounter), .checks(.isFullBodyVisible)],
                [.fitness(.squats), .checks(.isFullBodyVisible)],
                [.fitness(.pushUps), .checks(.isFullBodyVisible)],
                [.fitness(.jumpingJacks), .checks(.isFullBodyVisible)],
                [.fitness(.sumoSquats), .checks(.isFullBodyVisible)],
                [.fitness(.leftLegLunges), .checks(.isFullBodyVisible)],
                [.fitness(.rightLegLunges), .checks(.isFullBodyVisible)],
                [.fitness(.sitUps), .checks(.isFullBodyVisible)],
                [.fitness(.cobraWings), .checks(.isFullBodyVisible)],
                [.fitness(.plank), .checks(.isFullBodyVisible)]
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
        return ["General", "Input", "Fitness", "Health", "Conditional", "Sports"]
    }
}
