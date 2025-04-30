import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var objectivesViewModel: ObjectivesViewModel
    @State private var showOnboarding = false
    
    var body: some View {
        Group {
            if authViewModel.userSession != nil {
                if showOnboarding {
                    OnboardView(showContentView: $showOnboarding)
                } else {
                    MainView()
                }
            } else {
                LoginView()
            }
        }
        .onAppear {
            Task {
                try await authViewModel.reloadUser()
                checkIfFirstTimeUser()
            }
        }
    }
    
    private func checkIfFirstTimeUser() {
        let isFirstTime = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        if isFirstTime {
            showOnboarding = true
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        } else {
            showOnboarding = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthViewModel())
            .environmentObject(ObjectivesViewModel())
    }
}
