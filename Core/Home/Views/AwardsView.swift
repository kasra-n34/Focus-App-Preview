//
//  AwardsView.swift
//  Focus
//
//  Created by Adam on 2024-06-26.
//
import SwiftUI
import FirebaseAuth

import SwiftUI
import FirebaseAuth

struct MedalView: View {
    var progress: Int
    var goal: Int
    
    var body: some View {
        Circle()
            .stroke(lineWidth: 2)
            .foregroundColor(progress >= goal ? .yellow : .gray)
            .overlay(
                Image(systemName: "medal.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(progress >= goal ? .yellow : .gray)
            )
    }
}

struct AwardsView: View {
    @ObservedObject var viewModel: AwardsViewModel
    
    @State private var expandedStates: [String: Bool] = [:]
    
    init(userId: String) {
        let viewModel = AwardsViewModel()
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        List {
            ForEach(viewModel.awards, id: \.id) { award in
                VStack(alignment: .leading) {
                    AwardHeaderView(award: award, expandedStates: $expandedStates)
                    
                    if expandedStates[award.id ?? "unknown", default: false] {
                        ForEach(award.maxTiers, id: \.id) { tier in
                            TierView(tier: tier, progress: award.progress)
                        }
                        .transition(.opacity)
                        .animation(.easeInOut, value: expandedStates[award.id ?? "unknown", default: false])
                    }
                }
                .listRowBackground(Color.black) // Ensure each row's background is black
            }
        }
        .listStyle(PlainListStyle()) // Removes default list styling
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct AwardHeaderView: View {
    var award: Award
    @Binding var expandedStates: [String: Bool]
    
    var body: some View {
        HStack {
            MedalView(progress: award.progress, goal: award.goal)
                .frame(width: 50, height: 50)
                .padding(.leading, 10)
            
            VStack(alignment: .leading) {
                Text(award.title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text("Progress: \(award.progress)/\(award.goal)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            
            Button(action: {
                expandedStates[award.id ?? "unknown", default: false].toggle()
            }) {
                Image(systemName: "chevron.right.circle")
                    .rotationEffect(.degrees(expandedStates[award.id ?? "unknown", default: false] ? 90 : 0))
                    .animation(.easeInOut, value: expandedStates[award.id ?? "unknown", default: false])
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.black) // Background for the header
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct TierView: View {
    var tier: AwardTier
    var progress: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("\(tier.title): \(tier.description)")
                    .foregroundColor(.white)
            }
            Spacer()
            if progress >= tier.goal {
                Button("Equip") {
                    // Handle equip logic here
                }
                .padding(5)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(5)
            } else {
                Text("Equip")
                    .padding(5)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(5)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 5)
        .background(Color.gray.opacity(0.1)) // Slight background to differentiate tiers
        .cornerRadius(5)
        .shadow(radius: 2)
    }
}

struct AwardsView_Previews: PreviewProvider {
    static var previews: some View {
        AwardsView(userId: "sampleUserId")
    }
}
