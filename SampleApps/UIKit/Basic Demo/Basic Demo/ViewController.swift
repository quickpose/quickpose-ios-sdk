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
    var quickPose = QuickPose()
    
    @IBOutlet var cameraView: UIView!
    @IBOutlet var overlayView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup camera
        camera = QuickPoseCamera(useFrontCamera: true)
        try? camera?.start(delegate: quickPose)
        
        let customPreviewLayer = AVCaptureVideoPreviewLayer(session: camera!.session!)
        customPreviewLayer.videoGravity = .resizeAspectFill
        customPreviewLayer.frame.size = view.frame.size
        cameraView.layer.addSublayer(customPreviewLayer)
        
        // setup overlay
        overlayView.contentMode = .scaleAspectFill // keep overlays in same scale as camera output
        overlayView.frame.size = view.frame.size
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        quickPose.start(features: [.overlay(.userLeftArm)], onFrame: { status, image, features, landmarks in
            if case .success(_) = status {
                DispatchQueue.main.async {
                    self.overlayView.image = image
                }
            }
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        camera?.stop()
        quickPose.stop()
    }
}
