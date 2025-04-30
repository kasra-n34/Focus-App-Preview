import Foundation
import Firebase
import FirebaseMessaging

class SubscriptionViewModel {

    private let db = Firestore.firestore()
    private var userID: String? {
        return Auth.auth().currentUser?.uid
    }

    // Load user notification settings and manage subscriptions
    func manageUserSubscriptions() {
        guard let uid = userID else {
            print("User not logged in")
            return
        }

        db.collection("users").document(uid).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                _ = data?["objectiveReminderNotifications"] as? Bool ?? true
                let profileUpdates = data?["profileUpdateNotifications"] as? Bool ?? true
                let motivation = data?["motivationNotifications"] as? Bool ?? true
                
                // Manage subscriptions based on user preferences
                self.toggleSubscription(to: "profile_updates", enabled: profileUpdates)
                self.toggleSubscription(to: "motivation", enabled: motivation)
            } else {
                print("Document does not exist")
            }
        }
    }

    // Subscribe or unsubscribe from a topic
    func toggleSubscription(to topic: String, enabled: Bool) {
        if enabled {
            Messaging.messaging().subscribe(toTopic: topic) { error in
                if let error = error {
                    print("Failed to subscribe to \(topic): \(error.localizedDescription)")
                } else {
                    print("Subscribed to \(topic)")
                }
            }
        } else {
            Messaging.messaging().unsubscribe(fromTopic: topic) { error in
                if let error = error {
                    print("Failed to unsubscribe from \(topic): \(error.localizedDescription)")
                } else {
                    print("Unsubscribed from \(topic)")
                }
            }
        }
    }

    // Update notification settings in Firestore
    func updateNotificationSetting(setting: String, value: Bool) {
        guard let uid = userID else {
            print("User not logged in")
            return
        }

        db.collection("users").document(uid).setData([setting: value], merge: true) { error in
            if let error = error {
                print("Error updating \(setting): \(error.localizedDescription)")
            } else {
                print("\(setting) successfully updated")
            }
        }
    }

    // Disable all notifications
    func disableAllNotifications() {
        updateNotificationSetting(setting: "objectiveReminderNotifications", value: false)
        updateNotificationSetting(setting: "profileUpdateNotifications", value: false)
        updateNotificationSetting(setting: "motivationNotifications", value: false)

        toggleSubscription(to: "profile_updates", enabled: false)
        toggleSubscription(to: "motivation", enabled: false)
    }
}
