//
//  PublicCardView.swift
//  Focus
//
//  Created by Kasra on 2024-09-23.
//

import Foundation
import SwiftUI

struct PublicCardView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var profilePhotoURL: URL?
    @State private var focusRating: Int = 0
    @State private var physicalityRating: Int = 0
    @State private var mindfulnessRating: Int = 0
    @State private var professionRating: Int = 0

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.black]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        if let url = profilePhotoURL {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                    .shadow(radius: 5)
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 80, height: 80)
                            }
                        } else {
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 80, height: 80)
                                .overlay(Image(systemName: "person.fill").foregroundColor(.white))
                        }
                        
                        Text(username)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(email)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    VStack {
                        ZStack {
                            FocusRing(progress: .constant(Double(Float(focusRating)) / 100),
                                      color1: Color.gray, color2: Color.white)
                            .frame(width: 80, height: 80)
                            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                            
                            Text("\(focusRating)")
                                .font(.system(size: 25, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.white, Color.gray]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                    }
                    .padding(.trailing, 20)
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)
                
                Divider()
                    .background(Color.gray)
                    .padding(.horizontal, 20)
                
                HStack {
                    Text("User Stats")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.gray, Color.white]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 5)
                
                HStack(spacing: 25) {
                    MiniPillarCard(
                        title: "Physicality",
                        rating: physicalityRating,
                        color: .red,
                        icon: "figure.walk.circle.fill"
                    )
                    MiniPillarCard(
                        title: "Mindfulness",
                        rating: mindfulnessRating,
                        color: .green,
                        icon: "brain.head.profile.fill"
                    )
                    MiniPillarCard(
                        title: "Produvtivity",
                        rating: professionRating,
                        color: .blue,
                        icon: "briefcase.circle.fill"
                    )
                }
                .padding(.horizontal, 10)
                
                Spacer()
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Done")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 18/255, green: 18/255, blue: 18/255))
                        .cornerRadius(10)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            Task {
                await fetchUserData()
            }
        }
    }
    
    func fetchUserData() async {
        guard let currentUser = viewModel.currentUser else { return }
        
        username = currentUser.fullname
        email = currentUser.email
        profilePhotoURL = URL(string: currentUser.profilePhotoURL)
        focusRating = Int(currentUser.focusRating)
        physicalityRating = Int(currentUser.physicalityRating)
        mindfulnessRating = Int(currentUser.mindfulnessRating)
        professionRating = Int(currentUser.professionRating)
    }
}
