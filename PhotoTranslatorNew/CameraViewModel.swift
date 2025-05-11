//
//  CameraViewModel.swift
//  PhotoTranslator
//
//  Created by Piyush on 11/05/25.
//


import Foundation
import Combine
import UIKit
import AVFoundation

@MainActor
class CameraViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    private var session: AVCaptureSession?
    private var photoOutput = AVCapturePhotoOutput()
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    @Published var capturedImage: UIImage? = nil
    @Published var isCameraAvailable: Bool = true
    @Published var isTranslating: Bool = false
    @Published var translationResult: TranslationResult? = nil
    
    override init() {
        super.init()
        Task {
            await configureSession()
        }
    }
    
    func configureSession() async {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            await setupSession()
        case .notDetermined:
            let granted = await withCheckedContinuation { continuation in
                AVCaptureDevice.requestAccess(for: .video) {
                    continuation.resume(returning: $0)
                }
            }
            if granted {
                await setupSession()
            } else {
                await MainActor.run { self.isCameraAvailable = false }
            }
        default:
            await MainActor.run { self.isCameraAvailable = false }
        }
    }
    
    private func setupSession() async {
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = .photo
        
        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else {
            await MainActor.run { self.isCameraAvailable = false }
            return
        }
        session.addInput(input)
        
        guard session.canAddOutput(photoOutput) else {
            await MainActor.run { self.isCameraAvailable = false }
            return
        }
        session.addOutput(photoOutput)
       
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        
        await MainActor.run {
            self.session = session
            self.previewLayer = previewLayer
            self.isCameraAvailable = true
            session.commitConfiguration()
            session.startRunning()
        }
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else { return }
        Task { @MainActor in
            self.capturedImage = image
        }
    }
    
    func startTranslation() {
        Task { @MainActor in
            await translateIfNeeded()
        }
    }

    private func translateIfNeeded() async {
        guard let image = capturedImage else { return }
        isTranslating = true
        translationResult = nil
        do {
            let result = try await TranslationService.translate(image: image, targetLanguage: "Spanish")
            translationResult = result
        } catch {
            translationResult = nil
        }
        isTranslating = false
    }

    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
    }
    func photoOutput(_ output: AVCapturePhotoOutput, didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
    }

    func startSession() {
        session?.startRunning()
    }

    func stopSession() {
        session?.stopRunning()
    }
}
