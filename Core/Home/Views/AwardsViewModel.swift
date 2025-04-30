//
//  AwardsViewModel.swift
//  Focus
//
//  Created by Adam on 2024-07-31.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift


import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class AwardsViewModel: ObservableObject {
    @Published var awards: [Award] = []

    init() {
        // Define the hardcoded awards
        self.awards = [
            Award(title: "Workout Award", iconName: "star.fill", progress: 0, goal: 100, maxTiers: [
                AwardTier(title: "Steel Warrior", description: "Complete 20 workout sessions", goal: 20, tier: 1),
                AwardTier(title: "Iron Champion", description: "Complete 50 workout sessions", goal: 50, tier: 2),
                AwardTier(title: "Eats Metal", description: "Complete 100 workout sessions", goal: 100, tier: 3)
            ]),
            Award(title: "Steps Award", iconName: "star.fill", progress: 0, goal: 50000, maxTiers: [
                AwardTier(title: "Stride Starter", description: "Take 50,000 steps", goal: 50000, tier: 1),
                AwardTier(title: "Stride Legend", description: "Take 100,000 steps", goal: 100000, tier: 2),
                AwardTier(title: "Step Sensei", description: "Take 200,000 steps", goal: 200000, tier: 3)
            ]),
            Award(title: "Running Award", iconName: "star.fill", progress: 0, goal: 50, maxTiers: [
                AwardTier(title: "Trailblazer", description: "Run 50 kilometers", goal: 50, tier: 1),
                AwardTier(title: "Pathfinder", description: "Run 100 kilometers", goal: 100, tier: 2),
                AwardTier(title: "Marathon Master", description: "Run 200 kilometers", goal: 200, tier: 3)
            ]),
            Award(title: "Sports Award", iconName: "star.fill", progress: 0, goal: 20, maxTiers: [
                AwardTier(title: "Rookie Ace", description: "Spend 20 hours playing sports", goal: 20, tier: 1),
                AwardTier(title: "Pro Player", description: "Spend 50 hours playing sports", goal: 50, tier: 2),
                AwardTier(title: "All-Star Ace", description: "Spend 100 hours playing sports", goal: 100, tier: 3)
            ]),
            Award(title: "Prayer Award", iconName: "star.fill", progress: 0, goal: 50, maxTiers: [
                AwardTier(title: "Spirit Seeker", description: "Complete 50 prayer sessions", goal: 50, tier: 1),
                AwardTier(title: "Faithful Soul", description: "Complete 100 prayer sessions", goal: 100, tier: 2),
                AwardTier(title: "Divine Devotee", description: "Complete 200 prayer sessions", goal: 200, tier: 3)
            ]),
            Award(title: "Meditation Award", iconName: "star.fill", progress: 0, goal: 20, maxTiers: [
                AwardTier(title: "Peaceful Practitioner", description: "Complete 20 meditation sessions", goal: 20, tier: 1),
                AwardTier(title: "Calm Connoisseur", description: "Complete 50 meditation sessions", goal: 50, tier: 2),
                AwardTier(title: "Tranquil Guru", description: "Complete 100 meditation sessions", goal: 100, tier: 3)
            ]),
            Award(title: "Screen Time Award", iconName: "star.fill", progress: 0, goal: 10, maxTiers: [
                AwardTier(title: "Digital Declutterer", description: "Reduce screen time to less than 2 hours a day for 10 days", goal: 10, tier: 1),
                AwardTier(title: "Tech Tamer", description: "Reduce screen time to less than 2 hours a day for 20 days", goal: 20, tier: 2),
                AwardTier(title: "Digital Detoxer", description: "Reduce screen time to less than 2 hours a day for 30 days", goal: 30, tier: 3)
            ]),
            Award(title: "Journaling Award", iconName: "star.fill", progress: 0, goal: 20, maxTiers: [
                AwardTier(title: "Diary Dabbler", description: "Write 20 journal entries", goal: 20, tier: 1),
                AwardTier(title: "Thought Weaver", description: "Write 50 journal entries", goal: 50, tier: 2),
                AwardTier(title: "Mindful Scribe", description: "Write 100 journal entries", goal: 100, tier: 3)
            ]),
            Award(title: "To-Do List Award", iconName: "star.fill", progress: 0, goal: 50, maxTiers: [
                AwardTier(title: "Busy Bee", description: "Complete 50 to-do list tasks", goal: 50, tier: 1),
                AwardTier(title: "Queen Bee", description: "Complete 100 to-do list tasks", goal: 100, tier: 2),
                AwardTier(title: "Task Overlord", description: "Complete 200 to-do list tasks", goal: 200, tier: 3)
            ])
        ]
    }
}
