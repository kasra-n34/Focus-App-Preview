import Foundation
import Firebase
import UserNotifications

class NotificationsViewModel: ObservableObject {
    @Published var objectiveReminders: Bool = true
    @Published var motivationNotifications: Bool = true
    @Published var profileUpdateNotifications: Bool = true

    private let subscriptionManager = SubscriptionViewModel()

    func loadCurrentNotificationSettings(objectivesViewModel: ObjectivesViewModel) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.objectiveReminders = data?["objectiveReminderNotifications"] as? Bool ?? true
                self.motivationNotifications = data?["motivationNotifications"] as? Bool ?? true
                self.profileUpdateNotifications = data?["profileUpdateNotifications"] as? Bool ?? true

                // Update the global state for objective reminders
                objectivesViewModel.objectiveRemindersEnabled = self.objectiveReminders

                // Ensure the subscriptions are correctly set according to the loaded settings
                self.subscriptionManager.manageUserSubscriptions()
            } else {
                print("Document does not exist")
            }
        }
    }

    func toggleObjectiveReminders(_ isOn: Bool, objectivesViewModel: ObjectivesViewModel) {
        objectiveReminders = isOn
        objectivesViewModel.objectiveRemindersEnabled = isOn
        subscriptionManager.updateNotificationSetting(setting: "objectiveReminderNotifications", value: isOn)

        if isOn {
            // Optionally, you could trigger re-scheduling of notifications here if needed
        } else {
            // Remove all pending objective reminders
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
    }

    func toggleProfileUpdates(_ isOn: Bool) {
        profileUpdateNotifications = isOn
        subscriptionManager.updateNotificationSetting(setting: "profileUpdateNotifications", value: isOn)
        subscriptionManager.toggleSubscription(to: "profile_updates", enabled: isOn)
    }

    func toggleMotivation(_ isOn: Bool) {
        motivationNotifications = isOn
        subscriptionManager.updateNotificationSetting(setting: "motivationNotifications", value: isOn)
        subscriptionManager.toggleSubscription(to: "motivation", enabled: isOn)
    }

    func disableAllNotifications(objectivesViewModel: ObjectivesViewModel) {
        objectiveReminders = false
        motivationNotifications = false
        profileUpdateNotifications = false

        // Update the global state for objective reminders
        objectivesViewModel.objectiveRemindersEnabled = false

        subscriptionManager.disableAllNotifications()
        
        self.toggleObjectiveReminders(false, objectivesViewModel: objectivesViewModel)
    }
}
