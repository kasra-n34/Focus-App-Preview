import Foundation
import SwiftUI
import Firebase

struct SettingsView: View {
    @State private var isDeleted = false

    var body: some View {
        if isDeleted {
            LoginView() // Navigate to LoginView
        } else {
            NavigationStack {
                ZStack {
                    Color(red: 28/255, green: 28/255, blue: 28/255).edgesIgnoringSafeArea(.all)

                    VStack(alignment: .leading, spacing: 10) {
                        headerView
                        Text("Manage your settings and preferences here.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)

                        SettingsList(onDelete: {
                            isDeleted = true // Update state to navigate to LoginView
                        })
                        Spacer()
                    }
                    .padding()
                }
            }
        }
    }

    var headerView: some View {
        HStack {
            Image(systemName: "gearshape.fill")
                .foregroundColor(.blue)
                .font(.title)

            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .padding(.top, 70)
        .padding(.leading, 20)
    }
}

struct SettingsList: View {
    @State private var showAlert = false
    @EnvironmentObject var viewModel: AuthViewModel
    let onDelete: () -> Void // Closure to handle deletion navigation

    var body: some View {
        VStack(spacing: 10) {
            NavigationLink(destination: AccountView()) {
                SettingsButton(iconName: "person.circle", text: "Account")
            }

            NavigationLink(destination: NotificationsView()) {
                SettingsButton(iconName: "bell", text: "Notifications")
            }

            NavigationLink(destination: FAQView()) {
                SettingsButton(iconName: "questionmark.circle", text: "FAQ's")
            }

            Button(action: {
                openEmail()
            }) {
                SettingsButtonContent(iconName: "envelope.fill", text: "Feedback/Contact Us")
            }
            .shadow(color: .white.opacity(0.2), radius: 5, x: 0, y: 0)

            NavigationLink(destination: ToSView()) {
                SettingsButton(iconName: "square.text.square", text: "Terms of Service")
            }

            NavigationLink(destination: EULAView()) {
                SettingsButton(iconName: "network", text: "EULA")
            }

            NavigationLink(destination: PrivacyPolicyView()) {
                SettingsButton(iconName: "lock.fill", text: "Privacy Policy")
            }

            Button(action: {
                showAlert = true // Show confirmation alert
            }) {
                SettingsButtonContent(iconName: "trash.fill", text: "Delete Account")
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Delete Account"),
                    message: Text("Are you sure you want to delete your account? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        Task {
                            do {
                                try await viewModel.deleteAccount(
                                    completion: { success in
                                        if success {
                                            print("Account deleted successfully")
                                        }
                                    },
                                    onReset: onDelete // Trigger navigation to LoginView
                                )
                            } catch {
                                print("Failed to delete account: \(error)")
                            }
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .shadow(color: .white.opacity(0.1), radius: 5, x: 0, y: 0)
        .padding(.horizontal, 20)
    }

    private func openEmail() {
        let email = "contact@focusapp.ca"
        if let url = URL(string: "mailto:\(email)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                print("Cannot open email client")
            }
        } else {
            print("Invalid email URL")
        }
    }
}

struct SettingsButton: View {
    let iconName: String
    let text: String

    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(.white)
            Text(text)
                .foregroundColor(.white)
                .padding(.leading, 10)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.white)
        }
        .padding()
        .background(Color(red: 18/255, green: 18/255, blue: 18/255))
        .cornerRadius(10)
        .shadow(color: .white.opacity(0.1), radius: 5, x: 0, y: 0)
        .padding(.horizontal, 0)
        .padding(.vertical, 5)
    }
}

struct SettingsButtonContent: View {
    let iconName: String
    let text: String

    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(.white)
            Text(text)
                .foregroundColor(.white)
                .padding(.leading, 10)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.white)
        }
        .padding()
        .background(Color(red: 18/255, green: 18/255, blue: 18/255))
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal, 0)
        .padding(.vertical, 5)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView().environmentObject(AuthViewModel())
    }
}
