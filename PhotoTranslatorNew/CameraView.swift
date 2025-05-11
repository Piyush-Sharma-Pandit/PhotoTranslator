//
//  CameraView.swift
//  PhotoTranslator
//
//  Created by Piyush on 11/05/25.
//

import PhotosUI
import SwiftUI

struct CameraView: View {
    @StateObject private var viewModel = CameraViewModel()
    @State private var isFlashing = false
    @State private var navigateToResult = false
    @State private var photoPickerImage: UIImage? = nil
    @State private var pickerItem: PhotosPickerItem? = nil
    @State private var showPhotoPicker = false

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundView
                postCapturePreTranslationView
                processingOverlayView
                flashOverlayView
                bottomBarView
            }
            .task {
                await viewModel.configureSession()
                updateCameraSession()
            }
            .navigationDestination(isPresented: $navigateToResult) {
                if let result = viewModel.translationResult, let capturedImage = viewModel.capturedImage {
                    TranslationResultView(
                        image: capturedImage,
                        translatedText: result.translated_text,
                        detectedLanguage: result.detected_language
                    ) {
                        viewModel.capturedImage = nil
                        viewModel.translationResult = nil
                        navigateToResult = false
                    }
                }
            }
            .onChange(of: viewModel.translationResult) { _, _ in
                navigateToResult = viewModel.translationResult != nil
                updateCameraSession()
            }
            .onChange(of: navigateToResult) { _, _ in
                if navigateToResult == false {
                    viewModel.capturedImage = nil
                    viewModel.translationResult = nil
                }
                updateCameraSession()
            }
            .onChange(of: viewModel.isTranslating) { _, _ in
                updateCameraSession()
            }
            .photosPicker(isPresented: $showPhotoPicker, selection: $pickerItem, matching: .images, photoLibrary: .shared())
            .onChange(of: pickerItem) { _, newItem in
                guard let item = newItem else { return }
                item.loadTransferable(type: Data.self) { result in
                    if case let .success(data?) = result, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.photoPickerImage = nil
                            viewModel.capturedImage = image
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        if viewModel.capturedImage == nil && photoPickerImage == nil {
            if let previewLayer = viewModel.previewLayer {
                CameraPreviewView(previewLayer: previewLayer)
                    .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
            }
        }
    }

    @ViewBuilder
    private var postCapturePreTranslationView: some View {
        if let capturedImage = viewModel.capturedImage,
           !viewModel.isTranslating,
           viewModel.translationResult == nil {
            VStack {
                Spacer()
                Image(uiImage: capturedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .background(Color.black.opacity(0.7))
                    .ignoresSafeArea()
                HStack(spacing: 32) {
                    Button(action: {
                        viewModel.capturedImage = nil
                    }) {
                        Text("Retry")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 14)
                            .background(Color.red)
                            .cornerRadius(10)
                            .shadow(radius: 3)
                    }

                    Button(action: {
                        viewModel.startTranslation()
                    }) {
                        Text("Translate")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 14)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .shadow(radius: 3)
                    }
                }
                .padding(.top, 34)
                Spacer()
            }
        }
    }

    @ViewBuilder
    private var processingOverlayView: some View {
        if viewModel.isTranslating, let capturedImage = viewModel.capturedImage {
            Image(uiImage: capturedImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .background(Color.black.opacity(0.7))
                .ignoresSafeArea()
            ZStack {
                Color.black.opacity(0.7).ignoresSafeArea()
                VStack(spacing: 24) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
                        .scaleEffect(2.0)
                        .padding(.bottom, 10)
                    Text("Translating...")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                }
                .padding(.top, 60)
            }
        }
    }

    @ViewBuilder
    private var flashOverlayView: some View {
        if isFlashing {
            Color.white
                .opacity(0.7)
                .ignoresSafeArea()
                .transition(.opacity)
        }
    }

    @ViewBuilder
    private var bottomBarView: some View {
        VStack {
            Spacer()
            if viewModel.capturedImage == nil && photoPickerImage == nil && viewModel.translationResult == nil && !viewModel.isTranslating {
                HStack(spacing: 40) {
                    Button(action: {
                        showPhotoPicker = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color(.systemGray6))
                                .frame(width: 48, height: 48)
                                .shadow(radius: 3)
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(.blue)
                        }
                    }
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.15)) { isFlashing = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                            withAnimation(.easeIn(duration: 0.15)) { isFlashing = false }
                        }
                        viewModel.capturePhoto()
                    }) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 70, height: 70)
                            .shadow(radius: 8)
                            .overlay(
                                Circle()
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 4)
                                    .frame(width: 84, height: 84)
                            )
                    }
                }
                .padding(.bottom, 40)
            }
        }
    }

    private func updateCameraSession() {
        if viewModel.capturedImage == nil && viewModel.translationResult == nil && !viewModel.isTranslating {
            viewModel.startSession()
        } else {
            viewModel.stopSession()
        }
    }
}
