//
//  OnboardView.swift
//  Focus
//
//  Created by Kasra on 2024-06-21.

import SwiftUI
import HealthKit

import SwiftUI

struct OnboardView: View {
    @State private var healthStore = HKHealthStore()
    @State private var isAuthorizingHealthKit = false
    @Binding var showContentView: Bool
    @State private var currentPageIndex = 0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // 🔥 Floating Light Orbs
            FloatingOrbsView()

            VStack {
                TabView(selection: $currentPageIndex) {
                    OnboardingPageView1().tag(0)
                    OnboardingPageView2().tag(1)
                    OnboardingPageView3().tag(2)
                    OnboardingPageView4().tag(3)
                    OnboardingPageView5().tag(4)
                }
                .tabViewStyle(PageTabViewStyle())

                Spacer()

                if isAuthorizingHealthKit {
                    ProgressView("Authorizing HealthKit...")
                        .padding()
                        .foregroundColor(.white)
                } else {
                    Button(action: {
                        authorizeHealthKit()
                    }) {
                        Text("Jump in")
                            .padding()
                            .frame(width: 300)
                            .background(currentPageIndex == 4 ? Color.indigo : Color(red: 18/255, green: 18/255, blue: 18/255))
                            .foregroundColor(currentPageIndex == 4 ? Color.white : Color(red: 78/255, green: 78/255, blue: 78/255))
                            .cornerRadius(10)
                    }
                    .disabled(currentPageIndex < 4)
                }
            }
        }
    }

    private func authorizeHealthKit() {
        isAuthorizingHealthKit = true

        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.workoutType()
        ]

        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            DispatchQueue.main.async {
                isAuthorizingHealthKit = false
                if success {
                    print("HealthKit authorization successful.")
                    completeOnboarding()
                } else if let error = error {
                    print("Authorization failed: \(error.localizedDescription)")
                } else {
                    print("HealthKit authorization failed.")
                }
            }
        }
    }

    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        showContentView = false
    }
}

// MARK: - 🔥 Floating Light Orbs Background
struct FloatingOrbsView: View {
    private let orbCount = 10  // Increased the number of orbs
    private let orbSize: CGFloat = 30  // Reduced orb size

    @State private var positions: [CGSize] = (0..<15).map { _ in
        CGSize(width: CGFloat.random(in: 0...UIScreen.main.bounds.width),
               height: CGFloat.random(in: 0...UIScreen.main.bounds.height))
    }

    var body: some View {
        ZStack {
            ForEach(0..<orbCount, id: \.self) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.indigo.opacity(0.18), // Softer glow
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 2,  // Smaller inner glow
                            endRadius: 25    // Reduced outer glow
                        )
                    )
                    .frame(width: orbSize, height: orbSize)
                    .position(x: positions[index].width, y: positions[index].height)
                    .blur(radius: 8)  // Slightly reduced blur for a subtler effect
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 3.0...7.0))  // Varying movement speed
                            .repeatForever(autoreverses: true),
                        value: positions
                    )
            }
        }
        .onAppear {
            moveOrbs()
        }
    }

    private func moveOrbs() {
        for i in positions.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.5) { // Staggered movement
                positions[i] = CGSize(
                    width: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    height: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                )
            }
        }
    }
}


struct OnboardingPageView1: View {
    var body: some View {
        ZStack {
            
            
            VStack {
                
                Spacer()
                
                Text("Welcome to Focus")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                
                
                Text("A New Chapter In Your Life.")
                    .foregroundColor(.gray)
                
                Spacer()
                
                ForEach(onboardingData) { item in
                    HStack {
                        Spacer()
                        Image(systemName: item.imageName)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .font(.system(size: 25))
                            .padding(.trailing, 20)
                            
                       
                        VStack {
                            Text(item.title)
                                .font(.title3)
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: 250)
                                .foregroundColor(.white)
                            
                            Text(item.description)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 260)
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        }
                       
                        Spacer()
                    }
                    Spacer()
                }
                
                Spacer()
                Spacer()
                
            }
        }
    }
}

struct OnboardingPageView2: View {
    var body: some View {
        ZStack {
           
            VStack {
                
                Spacer()
                Spacer()
                
                ZStack {
                    Text("50")
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
                    .foregroundColor(.white)
                    .padding()
                Text("All-in-one rating of how effectively you are meeting your goals.")
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 350)
                
                Text("*Note: your Focus Rating starts at 50")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 350)
                    .padding(.top, 10)
                
                Spacer()
                Spacer()
                Spacer()
            }
            
        }
    }
}


struct OnboardingPageView3: View {
    @State private var physicalityPoints: Double = 4.0
    @State private var physicalityPointsToLevelUp: Double = 10.0
    @State private var productivityPoints: Double = 5.0
    @State private var productivityPointsToLevelUp: Double = 10.0
    @State private var mindfulnessPoints: Double = 8.0
    @State private var mindfulnessPointsToLevelUp: Double = 10.0
    @State private var physicalityRating: Double = 50.0
    @State private var mindfulnessRating: Double = 55.0
    @State private var productivityRating: Double = 60.0
    

    // Reusing the colors from HomePage
    let physicalityColor1 = Color.orange
    let physicalityColor2 = Color.red
    let productivityColor1 = Color.blue
    let productivityColor2 = Color.purple
    let mindfulnessColor1 = Color.orange
    let mindfulnessColor2 = Color.green
    let mindfulnessColor3 = Color.yellow

    var body: some View {
        VStack(spacing: 20.0) {
            Spacer()
            Spacer()
            
            Text("Focus Pillars")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
          
            
            Text("Your Focus Rating is a calculated average of these three ratings.")
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 350)

            PhysicalBarView(label: "Physicality", points: $physicalityPoints, pointsToLevelUp: $physicalityPointsToLevelUp, rating: $physicalityRating, color1: physicalityColor1, color2: physicalityColor2)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        self.physicalityPoints = 6.0
                    }
                }
            
            Text("*Includes physical fitness and diet.")
                .foregroundStyle(.gray)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: 350)
                .font(.caption)

            PhysicalBarView(label: "Productivity", points: $productivityPoints, pointsToLevelUp: $productivityPointsToLevelUp, rating: $productivityRating, color1: productivityColor1, color2: productivityColor2)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        self.productivityPoints = 4.0
                    }
                }
            
            Text("*Calculated from our built-in to-do list.")
                .foregroundStyle(.gray)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: 350)
                .font(.caption)

            PhysicalBarView(label: "Mindfulness", points: $mindfulnessPoints, pointsToLevelUp: $mindfulnessPointsToLevelUp, rating: $mindfulnessRating, color1: mindfulnessColor3, color2: mindfulnessColor2)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        self.mindfulnessPoints = 8.0
                    }
                }
            
            Text("*Includes mental wellness habits.")
                .foregroundStyle(.gray)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: 350)
                .font(.caption)

            Spacer()
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 25)
    }
}



struct OnboardingPageView4: View {
    var body: some View {
        ZStack {
            
        
            
            VStack {
                
                Spacer()
                Spacer()
                
                Text("Balance Your Goals")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    
                    .multilineTextAlignment(.center)
                
                Text("Be careful adding too many tasks at first. Start simple and build your way up.")
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 350)
                    .foregroundColor(.gray)
                    .padding(.bottom)
                    .padding(.bottom)
                
                HStack {
                    Spacer()
                    Image(systemName: "arrow.down.circle")
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .font(.system(size: 25))
                        .padding(.trailing)
                        
                    Spacer()
                    VStack {
                        Text("Decay Rate")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding()
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 250)
                            .foregroundColor(.white)
                        
                        Text("You lose points when you miss objectives.")
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 250)
                            .foregroundStyle(.gray)
                    }
                    
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    Image(systemName: "arrow.turn.right.up")
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .font(.system(size: 25))
                        .padding(.trailing)
                        
                    Spacer()
                    VStack {
                        Text("Exponential Difficulty")
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(maxWidth: 250)
                            .foregroundColor(.white)
                        
                        Text("It gets harder to level up over time. Never stay stagnant.")
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 250)
                            .foregroundColor(.gray)
                            
                    }
                   
                    Spacer()
                }
                
                Spacer()
                Spacer()
                Spacer()
                Spacer()

            }
        }
    }
}

struct OnboardingPageView5: View {
    var body: some View {
        ZStack {
            
            VStack {
                
                Spacer()
                Spacer()
                
                Image("icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 140, height: 140)
                   
                
                Spacer()
           
                
                Text("Don't Lose Focus")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .multilineTextAlignment(.center)
                Text("Jump in now and we'll help you along the way.")
                    .padding(.bottom)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
                
                Spacer()
                Spacer()
       
            }
            .padding(.bottom)
        }
    }
}

struct OnboardingItem: Identifiable {
    var id = UUID()
    var imageName: String
    var title: String
    var description: String
}

let onboardingData = [
    OnboardingItem(imageName: "figure.stand", title: "Reach Your Best Self", description: "In a world full of distractions, this app is designed to keep you focused."),
    OnboardingItem(imageName: "checklist.unchecked", title: "Set Clear Objectives", description: "Use our list of objectives to set clear goals and track your progress."),
    OnboardingItem(imageName: "circle.circle", title: "Stay Motivated", description: "A game-based approach to keep you conistent and engaged.")
]

struct OnboardView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardView(showContentView: .constant(true))
    }
}
