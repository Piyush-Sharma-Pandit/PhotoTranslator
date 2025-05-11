//
//  TranslationResultView.swift
//  PhotoTranslator
//
//  Created by Piyush on 11/05/25.
//

import SwiftUI

struct TranslationResultView: View {
    let image: UIImage
    let translatedText: String
    let detectedLanguage: String
    let onDismiss: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 320, maxHeight: 320)
                    .cornerRadius(18)
                    .shadow(radius: 8)
                VStack(spacing: 16) {
                    Text("Detected: \(detectedLanguage)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Translation:")
                        .font(.headline)
                    Text(translatedText)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.yellow)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 20)
                }
                Button {
                    onDismiss()
                } label: {
                    Text("Back to Camera")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                Spacer(minLength: 24)
            }
            .padding(.top, 48)
            .padding(.bottom, 32)
            .padding(.horizontal)
        }
        .background(Color.black.ignoresSafeArea())
    }
}
