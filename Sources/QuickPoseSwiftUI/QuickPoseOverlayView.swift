//
//  File.swift
//
//
//  Created by Peter Nash on 12/01/2023.
//

import Foundation
import SwiftUI

public struct QuickPoseOverlayView: View {
    let overlayImage: Binding<UIImage?>
    
    public init(overlayImage: Binding<UIImage?>) {
        self.overlayImage = overlayImage
    }
    
    public var body: some View {
        GeometryReader { reader in
            if let overlayImage = overlayImage.wrappedValue {
                Image(uiImage: overlayImage).resizable().aspectRatio(contentMode: .fill)
                    .frame(width: reader.size.width, height: reader.size.height)
            }
        }
    }
}

