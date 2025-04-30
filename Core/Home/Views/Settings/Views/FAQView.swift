//
//  FAQView.swift
//  Focus
//
//  Created by Kasra on 2024-07-13.
//

import Foundation
import SwiftUI

struct FAQCard: View {
    var question: String
    var answer: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(question)
                .font(.title2)
                .foregroundColor(.white)
                .fontWeight(.semibold)
                .padding(.top, 20)
                .padding(.bottom, 5)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text(answer)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 20)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .background(Color(red: 18/255, green: 18/255, blue: 18/255))
        .shadow(radius: 10)
        .cornerRadius(20)
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }
}

struct FAQView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 28/255, green: 28/255, blue: 28/255).edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading) {
                    headerView
                    Text("Find answers to common questions here.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                    
                    ScrollView {
                        VStack(spacing: 0) {
                            FAQCard(question: "My Focus Rating Hasn't Changed?",
                                    answer: "The Focus Rating updates on a weekly basis after analyzing your habits. Progress bars for the three pillars may update more often.")
                            FAQCard(question: "My Focus Rate Dropped?",
                                    answer: "Your Focus Rating drops when you do not complete objectives that you set for yourself. Only meeting your goal will improve your rating and avoid the rating decay.")
                            FAQCard(question: "What's the Focus Report?",
                                    answer: "A summary of your achievements and areas that need work. Coming Soon ;)")
                            FAQCard(question: "Can I Reset My Rating?",
                                    answer: "The only way to reset your rating is to delete your account and start fresh.")
                        }
                        .padding(.bottom, 10)
                    }
                }
            }
        }
    }
    
    var headerView: some View {
        HStack {
            Image(systemName: "questionmark.circle.fill")
                .foregroundColor(.blue)
                .font(.title)
            
            Text("FAQ")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .padding(.top, 30)
        .padding(.leading, 20)
    }
}

struct FAQView_Previews: PreviewProvider {
    static var previews: some View {
        FAQView()
    }
}
