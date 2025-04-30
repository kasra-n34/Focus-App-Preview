//
//  FocusApp.swift
//  Focus
//
//  Created by Abdul Basit on 2024-06-06.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import UserNotifications
import FirebaseMessaging
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    var db: Firestore!
    var objectivesViewModel: ObjectivesViewModel!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure() // Initialize Firebase
        
        // Initialize Firestore
        db = Firestore.firestore()
        
        // Enable HealthKit background delivery
        HealthKitManager.shared.enableBackgroundDelivery()
        
        // Start observing HealthKit data
        HealthKitManager.shared.startObservingHealthKitData()

        // Request notification permission for other notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted {
                print("Notification permission granted")
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            } else if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
        
        // Set the delegate for notification center
        UNUserNotificationCenter.current().delegate = self
        
        // Register for remote notifications
        application.registerForRemoteNotifications()
        
        // Set the messaging delegate to handle FCM token updates
        Messaging.messaging().delegate = self
                
        // Firestore settings to enable offline persistence
        let settings = FirestoreSettings()
        let cacheSettings = PersistentCacheSettings()
        settings.cacheSettings = cacheSettings
        db.settings = settings
        
        return true
    }
    
    // Handle APNs registration success
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    // Handle APNs registration failure
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register with push: \(error)")
    }

    // Handle FCM token updates
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")

        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        
        // Store the FCM token locally
        UserDefaults.standard.set(fcmToken, forKey: "fcmToken")
        
        // Save the token to the user's Firestore document if authenticated
        saveFCMTokenToFirestore(fcmToken)
    }

    // Save the FCM token to Firestore
    private func saveFCMTokenToFirestore(_ fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }
        
        let userRef = db.collection("users").document(userID)
        
        userRef.setData(["fcmToken": fcmToken], merge: true) { error in
            if let error = error {
                print("Error saving FCM token to Firestore: \(error.localizedDescription)")
            } else {
                print("FCM token successfully saved to Firestore")
            }
        }
    }
    
    // Handle notification when the app is in the foreground or background
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle silent push notifications
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Handle silent push notification
        print("Silent push notification received")
        
        // Trigger HealthKit data fetching or other background tasks
        HealthKitManager.shared.startObservingHealthKitData()
        
        // Notify the system that background fetch is complete
        completionHandler(.newData)
    }
}

@main
struct FocusApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate // Delegate for Firebase setup
    @StateObject private var authViewModel = AuthViewModel() // Initialize AuthViewModel
    @StateObject private var objectivesViewModel = ObjectivesViewModel() // Initialize ObjectivesViewModel
    @StateObject private var notificationsViewModel = NotificationsViewModel() // Initialize NotificationsViewModel

    var body: some Scene {
        WindowGroup {
            SplashScreenView() // Start with the splash screen
                .environmentObject(authViewModel) // Provide AuthViewModel as an environment object
                .environmentObject(objectivesViewModel) // Provide ObjectivesViewModel as an environment object
                .environmentObject(notificationsViewModel)
                .onAppear {
                    // Inject ObjectivesViewModel into AppDelegate
                    delegate.objectivesViewModel = objectivesViewModel
                    
                    // Delay this call to ensure everything is ready
                    DispatchQueue.main.async {
                        notificationsViewModel.loadCurrentNotificationSettings(objectivesViewModel: objectivesViewModel)
                    }
                }
        }
    }
}
