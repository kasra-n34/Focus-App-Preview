//
//  PointsExplanationView.swift
//  Focus
//
//  Created by Kasra on 2025-02-15.
//

import Foundation
import SwiftUI

struct PointsExplanationView: View {
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack {
                    Text("Point System Overview")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding()


                    Text("Points are awarded upon goal completion and decay if goals are unmet, affecting your rating. Ratings never drop below 50 and cap at 99. Your progress will reset each midnight for daily objectives and each Monday (12:00AM) for weekly objectives.")
                        .font(.system(size: 14, weight: .regular))
                        .multilineTextAlignment(.center)
                        .padding()
                        .foregroundStyle(.gray)
                
                Text("Physicality/Mindfulness goals earn 3 points upon completion. Productivity tasks without deadlines earn 2 points when checked off. Tasks with deadlines earn 3 points if completed by the set day's end.")
                    .font(.system(size: 14, weight: .regular))
                    .multilineTextAlignment(.center)
                    .padding()
                    .foregroundStyle(.gray)

                Spacer()
            
            }
        }
    }
}
