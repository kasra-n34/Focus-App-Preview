import SwiftUI
import FirebaseFirestore

struct AddFriendsView: View {
    @Binding var showAddFriends: Bool
    @ObservedObject private var viewModel = AddFriendsViewModel()

    @State private var isCreatingGroup = false
    @State private var selectedFriends = Set<String>() // Keep this in AddFriendsView
    @State private var groupName = ""
    @State private var expandedGroups = [String: Bool]()

    var body: some View {
        VStack {
            HeaderView(showAddFriends: $showAddFriends)

            ScrollView {
                VStack(spacing: 20) {
                    SearchBarView(viewModel: viewModel)

                    SearchResultsView(viewModel: viewModel)
                    PendingFriendRequestsView(viewModel: viewModel)
                    SentFriendRequestsView(viewModel: viewModel)
                    CurrentFriendsView(viewModel: viewModel, isCreatingGroup: $isCreatingGroup, selectedFriends: $selectedFriends) // Pass the binding
                    FriendGroupsView(viewModel: viewModel, expandedGroups: $expandedGroups)
                }
                .padding()
            }

            if isCreatingGroup {
                CreateGroupButtons(viewModel: viewModel, groupName: $groupName, isCreatingGroup: $isCreatingGroup, selectedFriends: $selectedFriends) // Pass the binding
            } else {
                CreateGroupButton(isCreatingGroup: $isCreatingGroup)
            }

            Spacer()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear {
            viewModel.fetchFriends()
            viewModel.fetchPendingFriendRequests()
            viewModel.fetchSentFriendRequests()
            viewModel.fetchFriendGroups()
        }
    }
}


struct HeaderView: View {
    @Binding var showAddFriends: Bool
    
    var body: some View {
        HStack {
            Text("Add Friends")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            Spacer()
            Button(action: {
                withAnimation {
                    showAddFriends = false
                }
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .padding()
            }
        }
        .padding(.top, 2)
    }
}

struct SearchBarView: View {
    @ObservedObject var viewModel: AddFriendsViewModel

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Enter username", text: $viewModel.searchUsername)
                .foregroundColor(.white)
                .padding(.vertical, 10)
                .padding(.horizontal, 5)
                .onChange(of: viewModel.searchUsername) { newValue in
                    viewModel.searchUsers(byUsername: newValue)
                }
        }
        .padding(.horizontal)
        .background(Color(red: 30/255, green: 30/255, blue: 30/255))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct SearchResultsView: View {
    @ObservedObject var viewModel: AddFriendsViewModel

    var body: some View {
        SectionHeaderView(title: "Search Results")
        ForEach(viewModel.searchResults) { user in
            SearchResultRow(user: user, viewModel: viewModel)
        }
    }
}

struct SearchResultRow: View {
    var user: User
    var viewModel: AddFriendsViewModel
    
    var body: some View {
        HStack {
            ProfileImageView(urlString: user.profilePhotoURL)
            VStack(alignment: .leading) {
                Text(user.fullname)
                    .foregroundColor(.white)
                    .font(.headline)
                Text(user.email)
                    .foregroundColor(.gray)
                    .font(.subheadline)
            }
            Spacer()
            Button(action: {
                viewModel.sendFriendRequest(to: user.id) { success in
                    if success {
                        viewModel.searchResults.removeAll { $0.id == user.id }
                    }
                }
            }) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.green)
                    .font(.title)
            }
        }
        .padding()
        .background(Color(red: 18/255, green: 18/255, blue: 18/255))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct PendingFriendRequestsView: View {
    @ObservedObject var viewModel: AddFriendsViewModel

    var body: some View {
        SectionHeaderView(title: "Pending Friend Requests")
        ForEach(viewModel.pendingFriends) { pendingFriend in
            FriendRequestRow(friend: pendingFriend, viewModel: viewModel, isPending: true)
        }
    }
}

struct SentFriendRequestsView: View {
    @ObservedObject var viewModel: AddFriendsViewModel

    var body: some View {
        SectionHeaderView(title: "Sent Friend Requests")
        ForEach(viewModel.sentFriends) { sentFriend in
            FriendRequestRow(friend: sentFriend, viewModel: viewModel, isPending: false)
        }
    }
}

struct CurrentFriendsView: View {
    @ObservedObject var viewModel: AddFriendsViewModel
    @Binding var isCreatingGroup: Bool
    @Binding var selectedFriends: Set<String>

    var body: some View {
        SectionHeaderView(title: "Current Friends")
        ForEach(viewModel.friends) { friend in
            FriendRow(
                friend: friend,
                isCreatingGroup: $isCreatingGroup,
                selectedFriends: $selectedFriends,
                viewModel: viewModel // Pass the viewModel here
            )
        }
    }
}



struct FriendGroupsView: View {
    @ObservedObject var viewModel: AddFriendsViewModel
    @Binding var expandedGroups: [String: Bool]

    var body: some View {
        SectionHeaderView(title: "Friend Groups")
        ForEach(viewModel.friendGroups) { group in
            FriendGroupRow(group: group, viewModel: viewModel, expandedGroups: $expandedGroups)
        }
    }
}

struct SectionHeaderView: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.leading)
    }
}

struct CreateGroupButton: View {
    @Binding var isCreatingGroup: Bool

    var body: some View {
        Button(action: {
            withAnimation {
                isCreatingGroup = true
            }
        }) {
            Text("Create a Group")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(10)
                .padding(.horizontal)
        }
    }
}

struct CreateGroupButtons: View {
    @ObservedObject var viewModel: AddFriendsViewModel
    @Binding var groupName: String
    @Binding var isCreatingGroup: Bool
    @Binding var selectedFriends: Set<String> // Bind to the local selectedFriends set

    var body: some View {
        VStack {
            TextField("Enter Group Name", text: $groupName)
                .padding()
                .background(Color.white.opacity(0.1))
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
            
            HStack {
                Button(action: {
                    guard !groupName.isEmpty, !selectedFriends.isEmpty else { return }
                    viewModel.createGroup(name: groupName, with: Array(selectedFriends)) { success in
                        if success {
                            isCreatingGroup = false
                            groupName = ""
                            selectedFriends.removeAll() // Clear selected friends
                        }
                    }
                }) {
                    Text("Create")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                }

                Button(action: {
                    isCreatingGroup = false
                    groupName = ""
                    selectedFriends.removeAll() // Clear selected friends
                }) {
                    Text("Cancel")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
        }
    }
}


struct ProfileImageView: View {
    let urlString: String?
    
    var body: some View {
        if let url = URL(string: urlString ?? "") {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .foregroundColor(.white)
            }
        } else {
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .foregroundColor(.white)
        }
    }
}

struct FriendRequestRow: View {
    var friend: User
    var viewModel: AddFriendsViewModel
    var isPending: Bool
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            HStack {
                ProfileImageView(urlString: friend.profilePhotoURL)
                VStack(alignment: .leading) {
                    Text(friend.fullname)
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding(.bottom,1)
                    Text(friend.email)
                        .foregroundColor(.gray)
                        .font(.system(size: 13, weight: .light, design: .monospaced))
                }
                Spacer()
                
                if isPending {
                    Button(action: {
                        viewModel.acceptFriendRequest(friendId: friend.id) { success in
                            if success {
                                viewModel.fetchFriends()
                                viewModel.fetchPendingFriendRequests()
                            }
                        }
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title)
                    }
                } else {
                    Text("Request Sent")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
            }
            .padding()
            .background(Color(red: 18/255, green: 18/255, blue: 18/255))
            .cornerRadius(10)
            .shadow(radius: 5)
            
            // Add a simple 'x' button for denying/cancelling friend requests
            if isPending {
                Button(action: {
                    viewModel.denyFriendRequest(friendId: friend.id) { success in
                        if success {
                            viewModel.fetchPendingFriendRequests()
                        }
                    }
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                        .font(.headline)
                        .padding(4)
                }
            }
        }
    }
}

struct FriendRow: View {
    var friend: User
    @Binding var isCreatingGroup: Bool
    @Binding var selectedFriends: Set<String>
    
    @ObservedObject var viewModel: AddFriendsViewModel // Add viewModel as an observed object

    @State private var showDeleteAlert = false // State to control alert presentation

    var body: some View {
        HStack {
            ProfileImageView(urlString: friend.profilePhotoURL)
            VStack(alignment: .leading) {
                Text(friend.fullname)
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding(.bottom,1)
                Text(friend.email)
                    .foregroundColor(.gray)
                    .font(.system(size: 13, weight: .light, design: .monospaced))
            }
            Spacer()

            if isCreatingGroup {
                Image(systemName: selectedFriends.contains(friend.id) ? "checkmark.square.fill" : "square")
                    .foregroundColor(.green)
                    .font(.title)
                    .onTapGesture {
                        if selectedFriends.contains(friend.id) {
                            selectedFriends.remove(friend.id)
                        } else {
                            selectedFriends.insert(friend.id)
                        }
                    }
            } else {
                // Friend remove button with alert
                Button(action: {
                    showDeleteAlert = true // Show the alert
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                        .font(.title)
                }
                .alert(isPresented: $showDeleteAlert) {
                    Alert(
                        title: Text("Remove Friend"),
                        message: Text("Are you sure you want to remove this friend?"),
                        primaryButton: .destructive(Text("Remove")) {
                            viewModel.removeFriend(friendId: friend.id) { success in
                                if success {
                                    print("Friend removed successfully")
                                } else {
                                    print("Failed to remove friend")
                                }
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
        }
        .padding()
        .background(Color(red: 18/255, green: 18/255, blue: 18/255))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}



struct FriendGroupRow: View {
    var group: FriendGroup
    var viewModel: AddFriendsViewModel
    @Binding var expandedGroups: [String: Bool]
    
    @State private var showDeleteAlert = false // State variable to control the alert

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "person.3.sequence.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 15))
                    .padding(.trailing, 8)
                VStack(alignment: .leading) {
                    Text(group.name)
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding(.bottom,1)
                    Text("\(group.members.count) members")
                        .foregroundColor(.gray)
                        .font(.system(size: 13, weight: .light, design: .monospaced))
                }
                Spacer()
                // Delete Group Button triggers the alert
                Button(action: {
                    showDeleteAlert = true
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                }
                .padding(.trailing, 5)
                
                // Chevron to indicate dropdown
                Image(systemName: expandedGroups[group.id] == true ? "chevron.up" : "chevron.down")
                    .foregroundColor(.white)
                    .padding(.vertical)
                    .padding(.leading)
            }
            .padding()
            .background(Color(red: 18/255, green: 18/255, blue: 18/255))
            .cornerRadius(10)
            .shadow(radius: 5)
            .onTapGesture {
                withAnimation {
                    expandedGroups[group.id]?.toggle() ?? {
                        expandedGroups[group.id] = true
                    }()
                }
            }
            
            // Dropdown list of members
            if expandedGroups[group.id] == true {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(group.members, id: \.self) { memberID in
                        MemberRow(memberID: memberID, viewModel: viewModel, groupID: group.id)
                    }
                }
                .background(Color(red: 18/255, green: 18/255, blue: 18/255))
                .cornerRadius(10)
            }
        }
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Delete Group"),
                message: Text("Are you sure you want to delete this group? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    viewModel.deleteGroup(groupID: group.id) { success in
                        if success {
                            // Additional handling if needed after deletion
                        }
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}


struct MemberRow: View {
    var memberID: String
    var viewModel: AddFriendsViewModel
    var groupID: String

    var body: some View {
        HStack {
            Text(viewModel.memberNames[memberID] ?? "Loading...")
                .foregroundColor(.white)
                .font(.subheadline)
                .padding(.leading)
            Spacer()
            Button(action: {
                print("Button pressed") // Confirm the button press is working
                // Directly call the removeMember function without showing an alert
                print("Removing member...")
                viewModel.removeMember(from: groupID, memberID: memberID) { success in
                    if success {
                        print("Member removed successfully")
                    } else {
                        print("Failed to remove member")
                    }
                }
            }) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
                    .padding(.trailing)
            }
        }
        .padding(.vertical)
        .cornerRadius(10)
    }
}


