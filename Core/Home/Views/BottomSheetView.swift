//
//  BottomSheetView.swift
//  Focus
//
//  Created by Adam on 2024-06-26.
//

import Foundation
import SwiftUI

struct BottomSheetView: View {

    @Binding var physicalBar: Float
    @Binding var professionBar: Float
    @Binding var mindfulnessBar: Float

    let physicalityColor1: Color
    let physicalityColor2: Color
    let professionColor1: Color
    let professionColor2: Color
    let mindfulnessColor1: Color
    let mindfulnessColor2: Color

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                PillarButton(
                    title: "Physicality",
                    image: Image(systemName: "figure.walk"),
                    progress: $physicalBar,
                    color1: Color.red,
                    color2: Color.white
                )
                PillarButton(
                    title: "Productivity",
                    image: Image(systemName: "briefcase.fill"),
                    progress: $professionBar,
                    color1: professionColor1,
                    color2: Color.white
                )
                PillarButton(
                    title: "Mindfulness",
                    image: Image(systemName: "brain.head.profile"),
                    progress: $mindfulnessBar,
                    color1: Color.green,
                    color2: Color.white
                )
            }
            Text("By choosing one of these pillars, your experience will strongly follow you with this path.")
                .font(.footnote)
                .foregroundColor(.white)
                .padding(.top, 5)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(red: 18/255, green: 18/255, blue: 18/255))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct PillarButton: View {

    var title: String
    var image: Image
    @Binding var progress: Float
    var color1: Color
    var color2: Color

    var body: some View {
        Button(action: {
            // Action when the button is pressed
        }) {
            VStack {
                image
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(LinearGradient(gradient: Gradient(colors: [color1, color2]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .clipShape(Circle())
                Text(title)
                    .font(.footnote)
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.black.opacity(0.2))
            .cornerRadius(10)
            .shadow(radius: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
