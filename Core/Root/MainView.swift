import SwiftUI

struct MainView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // Set the background color with low opacity for transparency
        appearance.backgroundColor = UIColor(red: 5/255, green: 5/255, blue: 5/255, alpha: 1) // Adjust alpha to control transparency

        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        UITabBar.appearance().standardAppearance = appearance
    }

    var body: some View {
        
        TabView {
            HomePage()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            ObjectivesView() // Make sure ObjectivesView is defined in the project
                .tabItem {
                    Label("Objectives", systemImage: "list.bullet")
                }

            LeaderboardView() // No arguments needed
                .tabItem {
                    Label("Leaderboard", systemImage: "trophy")
                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
