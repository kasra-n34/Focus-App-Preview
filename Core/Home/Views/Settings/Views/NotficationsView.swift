import SwiftUI

struct NotificationsView: View {
    @StateObject private var viewModel = NotificationsViewModel()
    @EnvironmentObject var objectivesViewModel: ObjectivesViewModel

    var body: some View {
        ZStack {
            Color(red: 28/255, green: 28/255, blue: 28/255).edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 20) {
                Spacer()
                
                HStack {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.blue)
                        .font(.title)
                    
                    Text("Notifications")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                }
                .padding(.leading, 20)
                .foregroundColor(.white)
                
                Text("Manage your notification preferences below.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 20)
                    .fixedSize(horizontal: false, vertical: true)
                
                NotificationToggleView(
                    title: "Objective Reminders",
                    description: "Get notified when you create reminders for objectives.",
                    action: { isOn in viewModel.toggleObjectiveReminders(isOn, objectivesViewModel: objectivesViewModel) },
                    isOn: $viewModel.objectiveReminders
                )
                NotificationToggleView(
                    title: "Profile Updates",
                    description: "Get notified when there are updates to your profile.",
                    action: { isOn in viewModel.toggleProfileUpdates(isOn) },
                    isOn: $viewModel.profileUpdateNotifications
                )
                NotificationToggleView(
                    title: "Motivation",
                    description: "Get motivational notifications to help you stay focused.",
                    action: { isOn in viewModel.toggleMotivation(isOn) },
                    isOn: $viewModel.motivationNotifications
                )
                
                Spacer()
                Spacer()
                
                Button(action: {
                    viewModel.disableAllNotifications(objectivesViewModel: objectivesViewModel)
                }) {
                    Text("Disable All Notifications")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 88/255, green: 18/255, blue: 18/255))
                        .cornerRadius(10)
                        .padding(.bottom, 20)
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .onAppear {
            viewModel.loadCurrentNotificationSettings(objectivesViewModel: objectivesViewModel)
        }
    }
}

struct NotificationToggleView: View {
    var title: String
    var description: String
    var action: (Bool) -> Void = { _ in }
    @Binding var isOn: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding(.bottom, 5)
                    Text(description)
                        .foregroundColor(.gray)
                        .font(.subheadline)
                        .fixedSize(horizontal: false, vertical: true) // Allow text to wrap
                }
                Spacer()
                Toggle("", isOn: Binding(
                    get: { self.isOn },
                    set: { newValue in
                        self.isOn = newValue
                        self.action(newValue)
                    }
                ))
                .labelsHidden()
                .padding(.leading, 8)
                .alignmentGuide(.top) { _ in 0 } // Align toggle to top
                .tint(.blue) // Set the toggle color to blue when on
            }
            .padding()
            .background(Color(red: 18/255, green: 18/255, blue: 18/255))
            .cornerRadius(10)
        }
        .padding(.horizontal)
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView().environmentObject(ObjectivesViewModel())
    }
}
