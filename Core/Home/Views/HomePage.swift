import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

import SwiftUI

struct HomePage: View {
    @StateObject private var homePageModel = HomePageModel() // Replace with HomePageModel
    @State private var showingSettings = false
    @State private var showingJournalEntries = false
    @State private var showToast = false // State for showing the toast message
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.black, Color(red: 10/255, green: 10/255, blue: 10/255)]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(spacing: 14) {
                        // Welcome Header with Points to Level Up
                        HStack {
                            
                            VStack(alignment: .leading, spacing: 10) {
                                Text(Date(), formatter: dateFormatter)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .fontWeight(.semibold)
                                    .padding([.leading], 25.0)
                                    

                                Text("Summary")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding([.leading], 25.0)
                                    .padding(.bottom, 15)
                            }

                            
                            Spacer()
                            
                            Button(action: {
                                showingSettings.toggle()
                            }) {
                                Image(systemName: "gearshape")
                                    .foregroundColor(.gray)
                                    .font(.title)
                                    .padding(.trailing, 30)
                                    .padding(.bottom, 5)
                            }
                            .sheet(isPresented: $showingSettings) {
                                SettingsView()
                                    .presentationDetents([.large])
                            }
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 15)

                        // Static Focus Ring Card with pillars
                        FocusRingCardWithPillars()
                            .environmentObject(homePageModel) // Use HomePageModel here
                            .padding(.bottom, 15)
                            .padding(.horizontal, 20)
                            .frame(height: 200)

                        
                        VStack {
                            
                            // Pillars Section
                            VStack(spacing: 10) {
                                PhysicalBarView(
                                    label: "Physicality",
                                    points: .constant(Double(homePageModel.physicalityPoints)),
                                    pointsToLevelUp: .constant(Double(homePageModel.physicalityPointsToLevelUp)), rating: .constant(Double(homePageModel.physicalityRating)),
                                    color1: Color.orange,
                                    color2: Color.red
                                )
                                
                                PhysicalBarView(
                                    label: "Mindfulness",
                                    points: .constant(Double(homePageModel.mindfulnessPoints)),
                                    pointsToLevelUp: .constant(Double(homePageModel.mindfulnessPointsToLevelUp)),
                                    rating: .constant(Double(homePageModel.mindfulnessRating)),
                                    color1: Color.yellow,
                                    color2: Color.green
                                )
                                
                                PhysicalBarView(
                                    label: "Productivity",
                                    points: .constant(Double(homePageModel.professionPoints)),
                                    pointsToLevelUp: .constant(Double(homePageModel.professionPointsToLevelUp)), rating: .constant(Double(homePageModel.professionRating)),
                                    color1: Color.blue,
                                    color2: Color.purple
                                )
                            }
                            .padding(.horizontal, 15)
                     
                        }
                        .padding(.top, 10)


                        // Journal Entries Section
                        Button(action: { showingJournalEntries.toggle() }) {
                            HStack {
                                Spacer()
                                Image(systemName: "book")
                                    .foregroundColor(.gray)
                                    .fontWeight(.semibold)
                                Text("Journal Entries")
                                    .fontWeight(.semibold)
                                    .padding(.horizontal)
                                    .foregroundStyle(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.gray, Color(red: 155/255, green: 155/255, blue: 155/255)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .multilineTextAlignment(.leading)
                                    .padding(.vertical)
                                    
                                Spacer()
                            }
                            .padding()
                            
                            
                            
                            .background(Color(red: 15/255, green: 15/255, blue: 15/255))
                            .cornerRadius(10)

                        }
                        .padding(.bottom, 10)
                 
                        .padding(.horizontal, 15)
                        .sheet(isPresented: $showingJournalEntries) {
                            JournalListView()
                                .presentationDetents([.large])
                        }
                    }
                    .accentColor(Color(hue: 0.455, saturation: 0.043, brightness: 0.944, opacity: 0.915))
                    .buttonBorderShape(.automatic)
                }
                .scrollIndicators(.hidden)
                
            }
            .onAppear {
                Task {
                    await homePageModel.fetchUser() // Use HomePageModel's fetchUser
                }
            }
        }
    }
}
import SwiftUI

struct FocusRingCardWithPillars: View {
    @EnvironmentObject var homePageModel: HomePageModel // Use HomePageModel here
    @State private var showFocusRingExplanation = false // State to manage modal visibility

    var body: some View {
        ZStack {
            // Card content
            HStack(spacing: 20) {
                // Properly centered Focus Ring on the left
                VStack(alignment: .center) {
                    ZStack {
                        // FocusRing showing the overall focus rating
                        FocusRing(progress: .constant(homePageModel.focusRating / 100),
                                  color1: Color.red, color2: Color.indigo)
                            .frame(width: 170, height: 170)
                            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)

                        // Display the current focus rating as an integer
                        Text("\(Int(homePageModel.focusRating))")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.indigo, Color.red]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                Spacer()

                // Vertical Divider
                Divider()
                    .frame(width: 2, height: 160)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(red: 25/255, green: 25/255, blue: 25/255), Color(red: 85/255, green: 85/255, blue: 85/255)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                // Right Section with Ratings and Improved Styling
                VStack(alignment: .leading, spacing: 25) {
                    // Physicality Rating
                    VStack(alignment: .leading) {
                        Text("Physicality")
                            .font(.caption)
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.red, Color.orange]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        Text("\(Int(homePageModel.physicalityRating))")
                            .font(.headline)
                            .bold()
                            .foregroundColor(.red)
                    }

                    // Mindfulness Rating
                    VStack(alignment: .leading) {
                        Text("Mindfulness")
                            .font(.caption)
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.green, Color.yellow]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        Text("\(Int(homePageModel.mindfulnessRating))")
                            .font(.headline)
                            .bold()
                            .foregroundColor(.green)
                    }

                    // Productivity Rating
                    VStack(alignment: .leading) {
                        Text("Productivity")
                            .font(.caption)
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        Text("\(Int(homePageModel.professionRating))")
                            .font(.headline)
                            .bold()
                            .foregroundColor(.blue)
                    }
                }
                .padding(.trailing, 10)
            }
            .padding(.vertical, 30)
            .padding(.horizontal, 20)
            .background(Color(red: 15/255, green: 15/255, blue: 15/255))
            .cornerRadius(10)
        }
        .frame(height: 100)
        .onTapGesture {
            showFocusRingExplanation = true // Show the modal on tap
        }
        .sheet(isPresented: $showFocusRingExplanation) {
            FocusRingExplanation() // Present the FocusRingExplanation view
        }
    }
}


struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
            .environmentObject(HomePageModel()) // Preview with HomePageModel
    }
}
