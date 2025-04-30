//
//  FocusRingExplanation.swift
//  Focus
//
//  Created by Kasra on 2024-12-30.
//

import Foundation
import SwiftUI

struct FocusRingExplanation: View {
    
    @EnvironmentObject var homePageModel: HomePageModel // Use HomePageModel here
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack {
                
                ZStack {
                    Text("\((Int(homePageModel.focusRating)))")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.indigo, Color.red]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                        .foregroundColor(Color.white)
                    FocusRing(progress: .constant(0.50), // Fixed progress for Level 50
                              color1: Color.red, color2: Color.indigo)
                    .frame(width: 170.0, height: 170.0)
                    .padding(20.0)
                }
                
                
                
                Text("Focus Rating")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding()
                
                
                Text("An overall measure of your consistency. Calculated average of the three pillars.")
                    .font(.system(size: 14, weight: .regular))
                    .multilineTextAlignment(.center)
                    .padding()
                    .foregroundStyle(.gray)
                
        
            }
            .padding()
            .presentationDetents([.medium, .large]) // Half-modal presentation
        }
    }
}
