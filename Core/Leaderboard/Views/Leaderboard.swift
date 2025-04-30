import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct LeaderboardView: View {
    @State private var selectedObjective = "Steps"
    @State private var selectedInterval = "Weekly"
    @State private var selectedLeaderboard = "Public"
    @State private var showObjectivePicker = false
    @State private var showIntervalPicker = false
    @State private var showLeaderboardPicker = false
    @State private var showAddFriends = false
    @State private var showMessages = false
    @State private var userID: String = ""
    @State private var hasLoadedData = false
    @State private var contentOpacity: Double = 0.0
    @State private var leaderboards: [String] = ["Public", "Friends"]
    @State private var isFetchingData = false
    
    // ViewModel
    @ObservedObject private var viewModel = LeaderboardViewModel()

    // ViewModel for AddFriendsView
    @ObservedObject private var addFriendsViewModel = AddFriendsViewModel()
    
    let intervals = [
        "Weekly",
        "Monthly"
    ]
    
    // Compute the objectives based on the selected leaderboard
    var objectives: [String] {
        switch selectedLeaderboard {
        case "Public":
            return [
                "Steps",
                "Sleep",
                "Runs",
                "Cycling",
                "Stair Workouts",
                "Calories Burned",
                "Journaling"
            ]
        case "Friends":
            return [
                "Steps",
                "Sleep",
                "Workouts",
                "Runs",
                "Calories",
                "Prayers",
                "Reading",
                "Protein",
                "Sports",
                "Cycling",
                "Stair Workouts",
                "Calories Burned",
                "Journaling"
            ]
        default:
            // If a group is selected, use the same objectives as the friends leaderboard
            if leaderboards.contains(selectedLeaderboard) {
                return [
                    "Steps",
                    "Sleep",
                    "Workouts",
                    "Runs",
                    "Calories",
                    "Prayers",
                    "Reading",
                    "Protein",
                    "Sports",
                    "Cycling",
                    "Stair Workouts",
                    "Calories Burned",
                    "Journaling"
                ]
            } else {
                return []
            }
        }
    }

    var sortedUsers: [LeaderboardUser] {
        return viewModel.users.sorted {
            if $0.progress == $1.progress {
                return $0.fullname < $1.fullname
            }
            return $0.progress > $1.progress
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(red: 35/255, green: 0/255, blue: 35/255), Color(red: 0/255, green: 0/255, blue: 0/255)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            ScrollView(showsIndicators: false) {
                VStack {
                    HStack {
                        Text("Leaderboard")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .padding(.leading, 30)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                showAddFriends.toggle()
                            }
                        }) {
                            Image(systemName: "person.3.fill")
                                .foregroundColor(.white)
                                .font(.headline)
                                .padding(.trailing, 30)
                        }
                    }
                    .padding(.top, 20)
                    
                    HStack {
                        Button(action: {
                            showIntervalPicker.toggle()
                        }) {
                            HStack {
                                Text(selectedInterval)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .background(
                            LinearGradient(gradient: Gradient(colors: [.red, .indigo]), startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(20)
                        .shadow(color: .red.opacity(0.7), radius: 10, x: 0, y: 0)
                        .actionSheet(isPresented: $showIntervalPicker) {
                            ActionSheet(
                                title: Text("Select Interval"),
                                buttons: intervals.map { interval in
                                    .default(Text(interval)) {
                                        selectedInterval = interval
                                        withAnimation {
                                            contentOpacity = 0.0
                                        }
                                        viewModel.selectedInterval = interval
                                        viewModel.fetchLeaderboardData(for: selectedObjective) {
                                            withAnimation {
                                                contentOpacity = 1.0
                                            }
                                        }
                                    }
                                } + [.cancel()]
                            )
                        }

                        
                        Button(action: {
                            showObjectivePicker.toggle()
                        }) {
                            HStack {
                                Text(selectedObjective)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .background(
                            LinearGradient(gradient: Gradient(colors: [.red, .indigo]), startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(20)
                        .shadow(color: .red.opacity(0.7), radius: 10, x: 0, y: 0)
                        .actionSheet(isPresented: $showObjectivePicker) {
                            ActionSheet(
                                title: Text("Select Objective"),
                                buttons: objectives.map { objective in
                                        .default(Text(objective)) {
                                            selectedObjective = objective
                                            withAnimation {
                                                contentOpacity = 0.0
                                            }
                                            viewModel.selectedObjective = objective
                                            viewModel.fetchLeaderboardData(for: selectedObjective) {
                                                withAnimation {
                                                    contentOpacity = 1.0
                                                }
                                            }
                                        }
                                } + [.cancel()]
                            )
                        }
                        
                        Button(action: {
                            showLeaderboardPicker.toggle()
                        }) {
                            HStack {
                                Text(selectedLeaderboard)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .background(
                            LinearGradient(gradient: Gradient(colors: [.red, .indigo]), startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(20)
                        .shadow(color: .red.opacity(0.7), radius: 10, x: 0, y: 0)
                        .actionSheet(isPresented: $showLeaderboardPicker) {
                            ActionSheet(
                                title: Text("Select Leaderboard"),
                                buttons: leaderboards.map { leaderboard in
                                    .default(Text(leaderboard)) {
                                        withAnimation {
                                            contentOpacity = 0.0
                                        }

                                        // Check if switching to Public leaderboard from any group
                                        if leaderboard == "Public" && viewModel.selectedLeaderboard != "Public" {
                                            selectedObjective = "Steps" // Default to "Steps" when switching to Public
                                        } else if (leaderboard == "Public" || leaderboard == "Friends") && !objectives.contains(selectedObjective) {
                                            selectedObjective = "Steps" // Default to "Steps" for public/friends leaderboards
                                        }

                                        selectedLeaderboard = leaderboard
                                        viewModel.selectedLeaderboard = leaderboard

                                        viewModel.fetchLeaderboardData(for: selectedObjective) {
                                            withAnimation {
                                                contentOpacity = 1.0
                                            }
                                        }
                                    }
                                } + [.cancel()]
                            )

                        }
                        
                    }
                    
                    if viewModel.users.isEmpty {
                        VStack {
                            Spacer()
                            
                            Text("No data available")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding()
                                .multilineTextAlignment(.center)
                            
                            Spacer()
                        }
                    } else {
                        VStack(spacing: 5) {
                            HStack(spacing: 30) {
                                if sortedUsers.count > 1 {
                                    LeaderboardUserView(user: sortedUsers[1], position: 2, color: .gray)
                                }
                                if sortedUsers.count > 0 {
                                    LeaderboardUserView(user: sortedUsers[0], position: 1, color: .yellow)
                                }
                                if sortedUsers.count > 2 {
                                    LeaderboardUserView(user: sortedUsers[2], position: 3, color: .orange)
                                }
                            }
                            .padding(.bottom, 10)
                            .padding()
                            .opacity(contentOpacity)  // Add opacity animation
                            .onAppear {
                                withAnimation(.easeIn(duration: 0.5)) {
                                    contentOpacity = 1.0
                                }
                            }
                            
                            ForEach(Array(sortedUsers.dropFirst(3).enumerated()), id: \.element.id) { index, user in
                                LeaderboardUserRowView(user: user, position: index + 4)
                                    .opacity(contentOpacity)  // Add opacity animation
                                    .onAppear {
                                        withAnimation(.easeIn(duration: 0.5)) {
                                            contentOpacity = 1.0
                                        }
                                    }
                            }
                        }
                    }
                }
            }
            if showAddFriends {
                AddFriendsView(showAddFriends: $showAddFriends)
                    .transition(.move(edge: .trailing))
                    .zIndex(1) // Ensures that the AddFriendsView is on top
            }
            
        }
        .onAppear {
            guard let currentUser = Auth.auth().currentUser else {
                print("User not authenticated")
                return
            }
            self.userID = currentUser.uid
            viewModel.userID = currentUser.uid
            
            if !hasLoadedData {
                isFetchingData = true  // Start fetching data
                viewModel.fetchLeaderboardData(for: selectedObjective) {
                    isFetchingData = false  // End fetching data
                }
                viewModel.fetchUserGroups { fetchedGroups in
                    self.leaderboards = ["Public", "Friends"] + fetchedGroups
                }
                hasLoadedData = true
            }
        }
        // Refresh the leaderboard when AddFriendsView is closed
        .onChange(of: showAddFriends) { newValue in
            if !newValue { // This means AddFriendsView was closed
                // Fetch updated leaderboard data
                viewModel.fetchLeaderboardData(for: selectedObjective) {
                    withAnimation {
                        contentOpacity = 1.0
                    }
                }
                
                // Fetch updated list of user groups
                viewModel.fetchUserGroups { fetchedGroups in
                    self.leaderboards = ["Public", "Friends"] + fetchedGroups
                }
            }
        }

    }
}





struct LeaderboardUserView: View {
    var user: LeaderboardUser
    var position: Int
    var color: Color
    var body: some View {
        VStack {
            if let url = URL(string: user.profilePhotoURL), !user.profilePhotoURL.isEmpty {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 80, height: 80)
                    case .success(let image):
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(color, lineWidth: 5))
                            .shadow(color: color, radius: 10, x: 0, y: 0)
                            .padding(5)
                            .background(
                                Circle()
                                    .fill(LinearGradient(gradient: Gradient(colors: [color.opacity(0.5), color.opacity(0.2)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 90, height: 90)
                            )
                    case .failure:
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(color, lineWidth: 5))
                            .shadow(color: color, radius: 10, x: 0, y: 0)
                            .padding(5)
                            .background(
                                Circle()
                                    .fill(LinearGradient(gradient: Gradient(colors: [color.opacity(0.5), color.opacity(0.2)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 90, height: 90)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(color, lineWidth: 5))
                    .shadow(color: color, radius: 10, x: 0, y: 0)
                    .padding(5)
                    .background(
                        Circle()
                            .fill(LinearGradient(gradient: Gradient(colors: [color.opacity(0.5), color.opacity(0.2)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 90, height: 90)
                    )
            }
            Text(user.fullname.prefix(12))
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("Level \(Int(user.focusRating))")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 1)
            
            Text("\(user.progress)")
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(.white)
        }
    }
}

struct LeaderboardUserRowView: View {
    var user: LeaderboardUser
    var position: Int
    
    var body: some View {
        NavigationLink(destination: PublicCardView()) { // Navigate to PublicCard
            HStack {
                if let url = URL(string: user.profilePhotoURL), !user.profilePhotoURL.isEmpty {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 50, height: 50)
                        case .success(let image):
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .shadow(color: .white, radius: 5, x: 0, y: 0)
                        case .failure:
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .shadow(color: .white, radius: 5, x: 0, y: 0)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .padding(.horizontal, 5)
                } else {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .padding(.horizontal, 5)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .shadow(color: .white, radius: 5, x: 0, y: 0)
                }
                
                VStack(alignment: .leading) {
                    Text(user.fullname.prefix(15)) // Limits the fullName to 15 characters
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Text("Level \(Int(user.focusRating))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom,1)
                    
                }
                .padding(.horizontal, 5)
                
                Spacer()
                
                VStack{
                    Spacer()
                    Text("\(user.progress)")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.trailing, 5)
            }
            .padding()
            .padding(.vertical, 5)
            .background(Color(red: 15/255, green: 15/255, blue: 15/255))
            .cornerRadius(10)
            .padding([.leading, .trailing])
        }
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView()
    }
}

