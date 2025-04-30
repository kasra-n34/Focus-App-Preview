import SwiftUI
import HealthKit
import EventKit

struct DataUsageView: View {
    @State private var useMyFitnessPalData = false
    @State private var useAppleHealthData = false
    @State private var useAppleRemindersData = false
    @State private var useAppleJournalData = false
    
    @State private var showingHealthSettingsAlert = false

    private var healthStore = HKHealthStore()

    var body: some View {
        ZStack {
            Color(red: 28/255, green: 28/255, blue: 28/255).edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 20) {
                Spacer()
                
                HStack {
                    Image(systemName: "network")
                        .foregroundColor(.blue)
                        .font(.title)
                        
                    Text("Data Usage")
                        .multilineTextAlignment(.leading)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                }
                .padding(.top, 40)
                .padding(.leading, 20)
                .foregroundColor(.white)
                
                Text("Set your preferences for which data can be used here.")
                    .multilineTextAlignment(.leading)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                    .fixedSize(horizontal: false, vertical: true)

                DataUsageToggleView(
                    title: "Use Apple Health Data",
                    description: "Allow access to Apple Health fitness data.",
                    isOn: $useAppleHealthData
                ) { newValue in
                    if newValue {
                        requestHealthKitAuthorization()
                    } else {
                        showingHealthSettingsAlert = true
                    }
                }
                .alert(isPresented: $showingHealthSettingsAlert) {
                    Alert(
                        title: Text("Manage Health Permissions"),
                        message: Text("To manage Health permissions, go to the Settings app, select your app, and adjust the Health settings."),
                        dismissButton: .default(Text("Open Settings"), action: {
                            openAppSettings()
                        })
                    )
                }
                
                // Center the buttons
                HStack(spacing: 20) {
                    NavigationLink(destination: EULAView()) {
                        CardView(title: "View EULA")
                    }
                    
                    NavigationLink(destination: PrivacyPolicyView()) {
                        CardView(title: "Privacy Policy")
                    }
                }
                .padding(.bottom, 50)
                .frame(maxWidth: .infinity, alignment: .center) // Center the buttons horizontally

                Spacer()
            }
            .padding()
        }
        .onAppear {
            loadMyFitnessPalSetting { setting in
                useMyFitnessPalData = setting
            }
            checkHealthKitAuthorization()
            checkRemindersAuthorization()
            // Add any other checks for other settings if needed
        }
    }

    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }

    private func checkHealthKitAuthorization() {
        if HKHealthStore.isHealthDataAvailable() {
            let readTypes: Set<HKObjectType> = [
                HKObjectType.quantityType(forIdentifier: .stepCount)!,
                HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
                HKObjectType.workoutType()
            ]
            
            healthStore.getRequestStatusForAuthorization(toShare: [] , read: readTypes) { status, _ in
                DispatchQueue.main.async {
                    self.useAppleHealthData = (status == .unnecessary)
                }
            }
        }
    }

    private func requestHealthKitAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.workoutType()
        ]

        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            if success {
                DispatchQueue.main.async {
                    self.useAppleHealthData = true
                }
            } else {
                DispatchQueue.main.async {
                    self.useAppleHealthData = false
                }
            }

            if let error = error {
                print("HealthKit authorization error: \(error.localizedDescription)")
            }
        }
    }

    private func checkRemindersAuthorization() {
        _ = EKEventStore()
        let status = EKEventStore.authorizationStatus(for: .reminder)
        DispatchQueue.main.async {
            self.useAppleRemindersData = (status == .fullAccess)
        }
    }
}

struct DataUsageToggleView: View {
    var title: String
    var description: String
    @Binding var isOn: Bool
    var action: (Bool) -> Void = { _ in }

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

struct CardView: View {
    let title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color(red: 18/255, green: 18/255, blue: 18/255))
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}

struct DataUsageView_Previews: PreviewProvider {
    static var previews: some View {
        DataUsageView()
    }
}
