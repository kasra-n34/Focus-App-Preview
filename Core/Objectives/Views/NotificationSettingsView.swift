import SwiftUI

struct NotificationSettingsView: View {
    @Binding var notifications: [NotificationModel]
    @State private var tempNotifications: [NotificationModel] = []
    @State private var selectedDays: [String] = []
    @State private var time: Date = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date()
    var currentCategory: String?
    var onSetNotifications: ([NotificationModel]) -> Void

    @Environment(\.presentationMode) var presentationMode

    let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    init(notifications: Binding<[NotificationModel]>, currentCategory: String?, onSetNotifications: @escaping ([NotificationModel]) -> Void) {
        self._notifications = notifications
        self.currentCategory = currentCategory
        self.onSetNotifications = onSetNotifications
        self._tempNotifications = State(initialValue: notifications.wrappedValue) // Properly initialize tempNotifications here
    }

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.blue)
                        .font(.title)

                    Text("Set Notifications")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                }
                .padding(.leading, 30)
                
                Text("Select the days of the week and times you want to receive notifications.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 15)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 10) {
                    ForEach(daysOfWeek, id: \.self) { day in
                        Button(action: {
                            toggleDay(day)
                        }) {
                            Text(day.prefix(1))
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(selectedDays.contains(day) ? .black : .white)
                                .padding(10)
                                .frame(width: 45, height: 45) // Set fixed frame for uniform size
                                .background(selectedDays.contains(day) ? Color.white : Color(red: 38/255, green: 38/255, blue: 38/255))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.bottom, 5)
                .padding(.horizontal, 20)

                HStack {
                    Spacer()
                    DatePicker("Select Time", selection: $time, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .colorInvert() // Make the DatePicker text white
                    Spacer()
                }
                .padding(.bottom, 20)
                .padding(.horizontal, 20)

                Button(action: addNotification) {
                    Text("Add Notification")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedDays.isEmpty ? Color(red: 18/255, green: 18/255, blue: 18/255) : Color(red: 38/255, green: 38/255, blue: 38/255))
                        .foregroundColor(selectedDays.isEmpty ? Color(red: 68/255, green: 68/255, blue: 68/255) : Color.white)
                        .cornerRadius(10)
                }
                .disabled(selectedDays.isEmpty)
                .padding(.horizontal, 10)
                
                ScrollView {
                    VStack {
                        ForEach($tempNotifications, id: \.id) { $notification in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(notification.days.joined(separator: ", "))
                                        .foregroundColor(.white)
                                    Text(notification.timeFormatted)
                                        .foregroundColor(.white)
                                }
                                Spacer()
                                DatePicker("", selection: $notification.time, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    .frame(width: 100) // Ensure consistent width
                                    .colorInvert() // Make the DatePicker text white
                                Button(action: {
                                    deleteNotification(notification)
                                }) {
                                    Text("Delete")
                                        .foregroundColor(.red)
                                        .font(.caption)
                                        .padding(.leading, 20) // Add some padding between DatePicker and Delete button
                                }
                            }
                            .padding()
                            .background(Color(red: 38/255, green: 38/255, blue: 38/255))
                            .cornerRadius(10)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding()
                    .background(Color.black)
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                Button(action: saveNotifications) {
                    Text("Save Changes")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(canSaveChanges ? Color(red: 38/255, green: 38/255, blue: 38/255) : Color(red: 18/255, green: 18/255, blue: 18/255))
                        .foregroundColor(canSaveChanges ? Color.white : Color(red: 68/255, green: 68/255, blue: 68/255))
                        .cornerRadius(10)
                }
                .disabled(!canSaveChanges)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .padding(.top, 20)
        }
        .onAppear {
            tempNotifications = notifications // Fetch the existing notifications when the view appears
        }
    }

    private var canSaveChanges: Bool {
        tempNotifications != notifications // Enable save if the tempNotifications differ from the original notifications
    }

    private func toggleDay(_ day: String) {
        if selectedDays.contains(day) {
            selectedDays.removeAll { $0 == day }
        } else {
            selectedDays.append(day)
        }
    }

    private func addNotification() {
        guard !selectedDays.isEmpty else { return }
        let newNotification = NotificationModel(days: selectedDays, time: time)
        tempNotifications.append(newNotification)
        selectedDays = []
        time = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date()
    }

    private func deleteNotification(_ notification: NotificationModel) {
        if let index = tempNotifications.firstIndex(of: notification) {
            tempNotifications.remove(at: index)
        }
    }

    private func saveNotifications() {
        // Update the actual notifications only on save
        notifications = tempNotifications
        onSetNotifications(notifications) // Pass notifications back
        presentationMode.wrappedValue.dismiss() // Dismiss the view
    }
}
