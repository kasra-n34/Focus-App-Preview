import SwiftUI
import FirebaseAuth

struct ReminderSettingsView: View {
    @Binding var reminders: [ProfessionObjective]
    @State private var selectedTime: Date = Date()
    @State private var selectedDays: [String] = []
    @State private var showTimePickerForReminder: String? = nil
    var onSetReminders: ([ProfessionObjective]) -> Void

    let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    var body: some View {
        VStack {
            Text("Set Notifications")
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding()

            HStack(spacing: 10) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Button(action: {
                        toggleDay(day)
                    }) {
                        Text(day.prefix(3))
                            .font(.headline)
                            .foregroundColor(selectedDays.contains(day) ? .black : .white)
                            .padding()
                            .background(selectedDays.contains(day) ? Color.blue : Color.gray)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()

            DatePicker("Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .padding()

            Button(action: addNotification) {
                Text("Add Notification")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()

            ScrollView {
                ForEach($reminders, id: \.id) { $reminder in  // Use id of ProfessionObjective
                    NotificationCard(reminder: $reminder, showTimePickerForReminder: $showTimePickerForReminder, deleteAction: {
                        deleteReminder(reminder: reminder)
                    })
                    .padding(.vertical, 5)
                }
            }
            .padding(.horizontal)
            .background(Color.black)

            Button(action: saveNotifications) {
                Text("Set Notifications")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
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

        let newReminder = ProfessionObjective(
            id: UUID().uuidString, // Assign a new UUID as id
            title: "New Reminder",
            description: "Reminder Description",
            time: selectedTime,
            userID: Auth.auth().currentUser?.uid ?? "default_user_id"
        )
        reminders.append(newReminder)
        selectedDays = []
        selectedTime = Date()
    }

    private func deleteReminder(reminder: ProfessionObjective) {
        reminders.removeAll { $0.id == reminder.id }  // Compare by id
    }

    private func saveNotifications() {
        onSetReminders(reminders)
    }
}

struct NotificationCard: View {
    @Binding var reminder: ProfessionObjective
    @Binding var showTimePickerForReminder: String?
    @State private var isEditingTime = false
    var deleteAction: () -> Void

    var body: some View {
        VStack {
            HStack {
                if let time = reminder.time {
                    Text("Scheduled at \(formattedTime(date: time))")
                        .foregroundColor(.white)
                } else {
                    Text("No Time Set")
                        .foregroundColor(.white)
                }
                Spacer()
                Button(action: {
                    isEditingTime = true
                }) {
                    Text("Edit")
                        .foregroundColor(.blue)
                }
                Button(action: deleteAction) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            .padding()
            .background(Color(red: 18/255, green: 18/255, blue: 18/255))
            .cornerRadius(10)
            .sheet(isPresented: $isEditingTime) {
                DatePicker(
                    "Edit Time",
                    selection: Binding(
                        get: { reminder.time ?? Date() },
                        set: { reminder.time = $0 }
                    ),
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .padding()
                .background(Color.black)
            }
        }
    }

    private func formattedTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}
