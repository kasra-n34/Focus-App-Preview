//
//  PhysicalBarView.swift
//  Focus
//
//  Created by Kasra on 2024-08-27.
//
import Foundation
import SwiftUI

struct PhysicalBarView: View {
    var label: String
    @Binding var points: Double
    @Binding var pointsToLevelUp: Double
    @Binding var rating: Double
    var color1: Color
    var color2: Color

    @State private var showModal = false // State to track modal presentation

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.system(size: 18, weight: .semibold)) // Improved font
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.bottom, 4)

            HStack {
                // Focus Rating (Left)
                Text("\(Int(rating))")
                    .font(.system(size: 16, weight: .medium, design: .monospaced)) // Monospaced for numbers
                    .foregroundColor(.gray)

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background bar (Translucent)
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .foregroundColor(Color.gray.opacity(0.25)) // Lightened

                        // Foreground bar (Translucent with Glow Effect)
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .frame(width: geometry.size.width * CGFloat(points / pointsToLevelUp), height: 10)
                            .background(
                                LinearGradient(gradient: Gradient(colors: [color1.opacity(0.7), color2.opacity(0.7)]), startPoint: .leading, endPoint: .trailing)
                                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            )
                            .foregroundColor(.clear)
                            .shadow(color: color2.opacity(0.7), radius: 10, x: 0, y: 0) // Glow effect
                    }
                    .frame(height: 10)
                }
                .frame(height: 10) // This ensures the height of the progress bar is consistent

                // Focus Rating + 1 (Right)
                Text("\(Int(rating) + 1)")
                    .font(.system(size: 16, weight: .medium, design: .monospaced)) // Monospaced for numbers
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 5)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 14)
        .background(Color(red: 15/255, green: 15/255, blue: 15/255)) // Very dark gray background
        .cornerRadius(10)
        .onTapGesture {
            showModal = true // Show modal on tap
        }
        .sheet(isPresented: $showModal) {
            PillarExplanationView(label: label, points: $points, pointsToLevelUp: $pointsToLevelUp, rating: $rating, color1: color1, color2: color2)
        }
    }
}

struct PillarExplanationView: View {
    var label: String
    @Binding var points: Double
    @Binding var pointsToLevelUp: Double
    @Binding var rating: Double
    var color1: Color
    var color2: Color

    var body: some View {
        NavigationStack { // ✅ Wrap everything inside a NavigationStack
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 20) {
                    Text("\(label) Pillar")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top)

                    PhysicalBarView(label: label, points: $points, pointsToLevelUp: $pointsToLevelUp, rating: $rating, color1: color1, color2: color2)
                        .padding()

                    Text("You currently have \(Int(points))/\(Int(pointsToLevelUp)) points needed to increase your rating from \(Int(rating)) to \(Int(rating + 1)). As your rating increases, it will take more points to level up further.")
                        .font(.system(size: 14))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding()

                    // ✅ Now NavigationLink will work correctly
                    NavigationLink(destination: PointsExplanationView()) {
                        Text("How do points work?")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .underline()
                    }
                }
                .padding()
            }
            .presentationDetents([.fraction(0.55), .large]) // Modal style
        }
    }
}


struct PhysicalBarView_Previews: PreviewProvider {
    @State static var points: Double = 4
    @State static var pointsToLevelUp: Double = 10
    @State static var rating: Double = 60
    static var previews: some View {
        PhysicalBarView(label: "Physicality", points: $points, pointsToLevelUp: $pointsToLevelUp, rating: $rating, color1: .orange, color2: .red)
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
