//
//  File.swift
//  
//
//  Created by Peter Nash on 17/01/2023.
//

import Foundation
import AVFoundation
import UIKit
import SwiftUI

public struct QuickPoseAssetRenderView: UIViewRepresentable {
    
    public class VideoRenderUIView: UIView {
        public override class var layerClass: AnyClass {
            AVPlayerLayer.self
        }
        var videoPreviewLayer: AVPlayerLayer {
            return layer as! AVPlayerLayer
        }
    }
    
    let view = VideoRenderUIView()
    let player: AVPlayer
    let videoGravity: AVLayerVideoGravity
    
    public init(player: AVPlayer, videoGravity: AVLayerVideoGravity) {
        self.player = player
        self.videoGravity = videoGravity
    }
    public func makeUIView(context: Context) -> VideoRenderUIView {
        view.backgroundColor = .black
        view.videoPreviewLayer.player = player
        view.videoPreviewLayer.videoGravity = videoGravity
        return view
    }
    
    public  func updateUIView(_ uiView: VideoRenderUIView, context: Context) {
        
    }
}


//// MARK: - View for rendering video file contents
class VideoRenderUIView: UIView {
    private var renderLayer: AVPlayerLayer!

    var player: AVPlayer? {
        get {
            return renderLayer.player
        }
        set {
            renderLayer.player = newValue
        }
    }

    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        renderLayer = layer as? AVPlayerLayer
        renderLayer.videoGravity = .resizeAspect
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
