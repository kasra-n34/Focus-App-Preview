//
//  SplashScreenView.swift
//  Focus
//
//  Created by Kasra on 2024-08-13.
//

import Foundation
import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false

    var body: some View {
        VStack {
            if isActive {
                // Navigate to the main app view
                ContentView()
            } else {
                // Splash screen content
                VStack {
                    Image("TransparentFocusWhite") // Replace "YourLogo" with your actual image asset name
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200) // Adjust size as needed
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black) // Set background color
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    // Duration of the splash screen
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation {
                            self.isActive = true
                        }
                    }
                }
            }
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
