//
//  CameraPreviewView.swift
//  PhotoTranslator
//
//  Created by Piyush on 11/05/25.
//

import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewRepresentable {
    typealias UIViewType = PreviewView

    let previewLayer: AVCaptureVideoPreviewLayer?

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        if let previewLayer {
            view.setPreviewLayer(previewLayer)
        }
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        if let previewLayer {
            uiView.setPreviewLayer(previewLayer)
        }
    }

    class PreviewView: UIView {
        private var customPreviewLayer: AVCaptureVideoPreviewLayer?

        func setPreviewLayer(_ layer: AVCaptureVideoPreviewLayer) {
            customPreviewLayer?.removeFromSuperlayer()
            customPreviewLayer = layer
            layer.frame = bounds
            layer.videoGravity = .resizeAspectFill
            layer.needsDisplayOnBoundsChange = true
            layer.removeFromSuperlayer()
            self.layer.addSublayer(layer)
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            customPreviewLayer?.frame = bounds
        }
    }
}
