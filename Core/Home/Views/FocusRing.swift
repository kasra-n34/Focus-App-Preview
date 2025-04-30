//
//  FocusRing.swift
//  Focus
//
//  Created by Kasra on 2024-07-31.
//

import Foundation
import SwiftUI

struct FocusRing: View {
    @Binding var progress: Double
    var color1: Color
    var color2: Color

    var body: some View {
        ZStack {
            
            

            // Main ring progress indicator
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(LinearGradient(
                    gradient: Gradient(colors: [color1, color2]),
                    startPoint: .leading,
                    endPoint: .trailing),
                    style: StrokeStyle(lineWidth: 20.0, lineCap: .round, lineJoin: .round))
                .rotationEffect(Angle(degrees: 270.0))
                .shadow(color: color1.opacity(0.3), radius: 10, x: 0, y: 0) // Increased glow effect
                .shadow(color: color2.opacity(0.3), radius: 15, x: 0, y: 0) // Second shadow for more pronounced glow
                .animation(.linear, value: progress)

            // Add subtle inner shadow or glow effect
            Circle()
                .stroke(lineWidth: 2.0)
                .foregroundColor(.white.opacity(0.1)) // More subtle inner ring glow effect
        }
    }
}

struct FocusRing_Previews: PreviewProvider {
    static var previews: some View {
        FocusRing(progress: .constant(0.7), color1: .red, color2: .indigo)
            .frame(width: 160, height: 160)
    }
}
