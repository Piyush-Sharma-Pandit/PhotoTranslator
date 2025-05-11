//
//  TranslationService.swift
//  PhotoTranslator
//
//  Created by Piyush on 11/05/25.
//

import Foundation
import UIKit

struct TranslationResult: Decodable, Equatable {
    let detected_language: String
    let original_text: String
    let target_language: String
    let translated_text: String
}

class TranslationService {
    static let endpoint = "https://answers-ai-ios.replit.app/translate"
    
    static func translate(image: UIImage, targetLanguage: String) async throws -> TranslationResult {
        guard let imageData = image.pngData() else {
            throw NSError(domain: "ImageEncoding", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not encode image"])
        }
        let base64String = imageData.base64EncodedString()
        let payload = [
            "base64_image": "data:image/png;base64,\(base64String)",
            "target_language": targetLanguage
        ]
        let url = URL(string: endpoint)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(TranslationResult.self, from: data)
    }
}
