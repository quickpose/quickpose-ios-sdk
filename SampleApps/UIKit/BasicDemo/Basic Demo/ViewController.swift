//
//  ViewController.swift
//  Basic Demo
//
//  Created by QuickPose.ai on 23/01/2023.
//

import UIKit
import AVFoundation
import QuickPoseCore
import QuickPoseCamera

class ViewController: UIViewController {
    
    var camera: QuickPoseCamera?
    var simulatedCamera: QuickPoseSimulatedCamera?
    var quickPose = QuickPose(sdkKey: "YOUR SDK KEY HERE") // register for your free key at https://dev.quickpose.ai
    
    @IBOutlet var cameraView: UIView!
    @IBOutlet var overlayView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if ProcessInfo.processInfo.isiOSAppOnMac, let url = Bundle.main.url(forResource: "happy-dance", withExtension: "mov") {
            simulatedCamera = QuickPoseSimulatedCamera(useFrontCamera: true, asset: AVAsset(url: url)) // setup simulated camera
            try? simulatedCamera?.start(delegate: quickPose)
            
            let customPreviewLayer = AVPlayerLayer(player: simulatedCamera?.player)
            customPreviewLayer.videoGravity = .resizeAspectFill
            customPreviewLayer.frame.size = view.frame.size
            cameraView.layer.addSublayer(customPreviewLayer)
        } else {
            camera = QuickPoseCamera(useFrontCamera: true) // setup camera
            try? camera?.start(delegate: quickPose)
            
            let customPreviewLayer = AVCaptureVideoPreviewLayer(session: camera!.session!)
            customPreviewLayer.videoGravity = .resizeAspectFill
            customPreviewLayer.frame.size = view.frame.size
            cameraView.layer.addSublayer(customPreviewLayer)
        }
        
        
        // setup overlay
        overlayView.contentMode = .scaleAspectFill // keep overlays in same scale as camera output
        overlayView.frame.size = view.frame.size
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        quickPose.start(features: [.overlay(.arm(side: .left))], onFrame: { status, image, features, feedback, landmarks in
            DispatchQueue.main.async {
                self.overlayView.image = image
            }
            if case .success = status {
                
            } else {
                // show error feedback
            }
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        camera?.stop()
        quickPose.stop()
    }
}
