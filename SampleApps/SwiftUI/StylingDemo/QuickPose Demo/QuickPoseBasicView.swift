//
//  QuickPoseBasicView.swift
//  QuickPose Styling Demo
//
//  Created by QuickPose.ai on 12/12/2022.
//

import SwiftUI
import QuickPoseCore
import QuickPoseCamera
import QuickPoseSwiftUI

struct QuickPoseBasicView: View {
    @Environment(\.geometry) private var geometrySize
    @Environment(\.safeAreaInsets) private var safeAreaInsets

    // @State so the SDK instance survives view-struct recreation (e.g. the parent's
    // GeometryReader re-evaluating): otherwise menu actions capture a fresh, never-started
    // QuickPose and update() calls silently go to the wrong instance.
    @State private var quickPose = QuickPose(sdkKey: "YOUR SDK KEY HERE") // register for your free key at https://dev.quickpose.ai
    @State private var overlayImage: UIImage?
    @State private var useFrontCamera: Bool = true
    @State private var targetFPS: Double? = nil

    @State private var color: String = "White"
    @State private var lineWidth: String = "1.0"
    @State private var lineCap: String = "Round"
    @State private var linePattern: String = "Solid"
    @State private var effect: String = "None"
    @State private var outline: String = "Off"
    @State private var imageFill: String = "None"
    @State private var font: String = "System"
    @State private var letterSpacing: String = "0"

    var body: some View {
        ZStack(alignment: .top) {
            if ProcessInfo.processInfo.isiOSAppOnMac, let url = Bundle.main.url(forResource: "happy-dance", withExtension: "mov") {
                QuickPoseSimulatedCameraView(useFrontCamera: false, delegate: quickPose, video: url)
            } else {
                QuickPoseCameraSwitchView(useFrontCamera: $useFrontCamera, delegate: quickPose, frameRate: $targetFPS)
            }
            QuickPoseOverlayView(overlayImage: $overlayImage)
        }
        .onAppear {
            quickPose.start(features: selectedFeatures(), onFrame: { status, image, features, feedback, landmarks in
                overlayImage = image
                if case .success = status {

                } else {
                    // show error feedback
                }
            })
        }
        .onDisappear {
            quickPose.stop()
        }
        .overlay(alignment: .top) {
            HStack {
                Menu {
                    stylePicker("Color", selection: $color, options: ["White", "Green", "Red"])
                    stylePicker("Line Width", selection: $lineWidth, options: ["0.5", "1.0", "1.5", "2.0"])
                    stylePicker("Line Cap", selection: $lineCap, options: ["Round", "Butt", "Square"])
                    stylePicker("Pattern", selection: $linePattern, options: ["Solid", "Dashed", "Dotted"])
                    stylePicker("Effect", selection: $effect, options: ["None", "Shadow", "Glow"])
                    stylePicker("Outline", selection: $outline, options: ["Off", "On"])
                    stylePicker("Image Fill", selection: $imageFill, options: ["None", "Orange Glow", "Galaxy"])
                    stylePicker("Font", selection: $font, options: ["System", "Bungee"])
                    stylePicker("Letter Spacing", selection: $letterSpacing, options: ["0", "0.08", "0.15"])
                } label: {
                    Text(Image(systemName: "paintbrush.fill")) + Text(" Style: \(styleSummary())")
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
            Text("Powered by QuickPose.ai v\(quickPose.quickPoseVersion())") // remove logo here, but attribution appreciated
                .font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                .frame(height: 40 + safeAreaInsets.bottom, alignment: .center)
                .padding(.bottom, 0)
        }
        .frame(width: geometrySize.width + safeAreaInsets.leading + safeAreaInsets.trailing)
        .edgesIgnoringSafeArea(.all)
    }

    private func stylePicker(_ title: String, selection: Binding<String>, options: [String]) -> some View {
        Menu {
            // Plain buttons rather than a Picker: menu items are buttons and their
            // actions always run, so the update rides the same tap that sets the value.
            ForEach(options, id: \.self) { option in
                Button(action: {
                    selection.wrappedValue = option
                    quickPose.update(features: selectedFeatures())
                }) {
                    if option == selection.wrappedValue {
                        Label(option, systemImage: "checkmark")
                    } else {
                        Text(option)
                    }
                }
            }
        } label: {
            Text(title)
        }
    }

    private func styleSummary() -> String {
        var parts: [String] = []
        if color != "White" { parts.append(color) }
        if lineWidth != "1.0" { parts.append("\(lineWidth)x") }
        if lineCap != "Round" { parts.append(lineCap) }
        if linePattern != "Solid" { parts.append(linePattern) }
        if effect != "None" { parts.append(effect) }
        if outline == "On" { parts.append("Outlined") }
        if imageFill != "None" { parts.append(imageFill) }
        if font != "System" { parts.append(font) }
        if letterSpacing != "0" { parts.append("spacing \(letterSpacing)") }
        return parts.isEmpty ? "Default" : parts.joined(separator: ", ")
    }

    private func selectedFeatures() -> [QuickPose.Feature] {
        let style = selectedStyle()
        // The elbow angle keeps a measurement label on screen even when seated,
        // so the font and letter-spacing options are always visible.
        return [
            .overlay(.wholeBody, style: style),
            .measureAngleBody(origin: .elbow(side: .right), p1: .shoulder(side: .right), p2: .wrist(side: .right), clockwiseDirection: false, style: style),
        ]
    }

    private func selectedStyle() -> QuickPose.Style {
        let baseColor: UIColor
        switch color {
        case "Green": baseColor = .green
        case "Red": baseColor = .red
        default: baseColor = .white
        }

        let relativeLineWidth = Double(lineWidth) ?? 1

        let cap: QuickPose.Style.LineCap
        switch lineCap {
        case "Butt": cap = .butt
        case "Square": cap = .square
        default: cap = .round
        }

        let pattern: QuickPose.Style.LinePattern
        switch linePattern {
        case "Dashed": pattern = .dashed
        case "Dotted": pattern = .dotted
        default: pattern = .solid
        }

        let shadow: QuickPose.Style.Shadow?
        switch effect {
        case "Shadow": shadow = QuickPose.Style.Shadow(color: .black, radius: 14, offsetX: 0, offsetY: 10)
        case "Glow": shadow = QuickPose.Style.Shadow(color: baseColor, radius: 32, offsetX: 0, offsetY: 0)
        default: shadow = nil
        }

        return QuickPose.Style(
            relativeLineWidth: relativeLineWidth,
            color: baseColor,
            lineCap: cap,
            linePattern: pattern,
            shadow: shadow,
            outline: outline == "On" ? QuickPose.Style.Outline(color: .black, relativeWidth: 0.6) : nil,
            imageFill: imageFill == "None" ? nil : StyleTextures.image(named: imageFill),
            font: font == "Bungee" ? UIFont(name: "Bungee-Regular", size: 80) : nil,
            letterSpacing: Double(letterSpacing) ?? 0
        )
    }
}

/// Image fills: a real bundled photo (NASA Hubble Ultra Deep Field, public domain)
/// and one procedural orange radial gradient — any UIImage works here.
enum StyleTextures {
    private static var cache: [String: UIImage] = [:]

    static func image(named name: String) -> UIImage? {
        if let cached = cache[name] { return cached }
        let image: UIImage?
        switch name {
        case "Galaxy": image = UIImage(named: "galaxy")
        case "Orange Glow": image = orangeRadialGradient()
        default: image = nil
        }
        cache[name] = image
        return image
    }

    private static func orangeRadialGradient() -> UIImage {
        let size = CGSize(width: 360, height: 640)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let colors = [UIColor(red: 1, green: 0.85, blue: 0.3, alpha: 1).cgColor,
                          UIColor(red: 1, green: 0.45, blue: 0, alpha: 1).cgColor,
                          UIColor(red: 0.55, green: 0.05, blue: 0, alpha: 1).cgColor] as CFArray
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 0.5, 1])!
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            context.cgContext.drawRadialGradient(gradient, startCenter: center, startRadius: 0,
                                                 endCenter: center, endRadius: size.height * 0.7, options: [])
        }
    }
}
