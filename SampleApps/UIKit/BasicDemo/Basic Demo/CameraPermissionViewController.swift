//
//  CameraPermissionViewController.swift
//  Basic Demo
//
//  Created by QuickPose.ai on 10/04/2023.
//

import Foundation
import UIKit
import AVFoundation

class CameraPermissionViewController: UIViewController {
    
    override func viewDidLoad() {
        AVCaptureDevice.requestAccess(for: .video) { success in
            DispatchQueue.main.async {
                if success {
                    self.performSegue(withIdentifier: "hasPermissions", sender: nil)
                } else {
                    let alert = UIAlertController(title: "Camera", message: "Camera access is required to use this app", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}
