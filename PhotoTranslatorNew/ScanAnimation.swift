//
//  ScanAnimation.swift
//  PhotoTranslator
//
//  Created by Piyush on 11/05/25.
//

import SwiftUI

struct ScanAnimation: View {
    @State private var scanX: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Border around most of the screen
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.yellow, lineWidth: 5)
                    .frame(width: geo.size.width * 0.85, height: geo.size.height * 0.6)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                
                // Vertical scanning line
                Rectangle()
                    .fill(LinearGradient(gradient:
                        Gradient(colors: [Color.clear, Color.yellow.opacity(0.7), Color.yellow, Color.yellow.opacity(0.7), Color.clear]),
                        startPoint: .leading, endPoint: .trailing))
                    .frame(width: 8, height: geo.size.height * 0.57)
                    .position(
                        x: geo.size.width * 0.075 + scanX * geo.size.width * 0.85,
                        y: geo.size.height / 2
                    )
            }
            .onAppear {
                scanX = 0
                withAnimation(
                    Animation.linear(duration: 1.7)
                        .repeatForever(autoreverses: false)
                ) {
                    scanX = 1
                }
            }
        }
    }
}
