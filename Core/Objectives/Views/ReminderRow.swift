import SwiftUI
import Foundation
import FirebaseFirestore
import UserNotifications

struct ReminderRow: View {
    @Binding var reminder: ProfessionObjective
    @Binding var showTimePickerForReminder: String?
    @Binding var isEditReminderClosed: Bool
    @State private var isCompleted: Bool = false
    @State private var isVisible: Bool = true
    @State private var showingEditReminderView = false
    @EnvironmentObject var viewModel: ObjectivesViewModel
    
    var onDelete: () -> Void
    var onRefresh: () -> Void
    
    // Property to hold the reminder ID
    let reminderId: String

    // State variable to hold the temporary title
    @State var temporaryTitle: String = ""
    
    // Custom initializer to handle the bindings
    init(reminder: Binding<ProfessionObjective>, reminderId: String, showTimePickerForReminder: Binding<String?>, isEditReminderClosed: Binding<Bool>, onDelete: @escaping () -> Void, onRefresh: @escaping () -> Void) {
        self._reminder = reminder  // Bind the reminder
        self.reminderId = reminderId  // Use the reminderId passed to this view
        self._showTimePickerForReminder = showTimePickerForReminder
        self.onDelete = onDelete
        self.onRefresh = onRefresh
        self._temporaryTitle = State(initialValue: reminder.wrappedValue.title) // Initialize temporaryTitle with reminder's title
        self._isEditReminderClosed = isEditReminderClosed // Bind isEditReminderClosed correctly
    }

    var body: some View {
        if isVisible {
            HStack {
                // Checkmark Button
                Button(action: {
                    isCompleted.toggle()
                    if isCompleted {
                        addCheckOffTimeToReminder()
                        startDeletionTimer()
                    }
                }) {
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isCompleted ? .green : .gray)
                        .padding(10)
                        .contentShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())

                VStack(alignment: .leading, spacing: 10) { // Increased spacing
                    HStack {
                        // Conditionally render the dot only if there's a category
                        if let category = reminder.category, !category.isEmpty {
                            Circle()
                                .fill(colorForCategory(category))
                                .frame(width: 8, height: 8)  // Adjust size as needed
                        }

                        TextField("Title", text: $temporaryTitle, onCommit: {
                            print("Temporary title at commit: \(temporaryTitle)")  // Debugging line
                            reminder.title = temporaryTitle  // Update the binding with the new title
                            updateReminderInFirestore(title: temporaryTitle)  // Update Firestore
                        })
                        .font(.headline)
                        .foregroundColor(isCompleted ? .gray : .white)
                        .strikethrough(isCompleted, color: .gray)
                    }
                    .padding(.leading, 10)

                    if let time = reminder.time {
                        Text("\(formattedTime(date: time))")
                            .font(.system(size: 13, weight: .medium, design: .monospaced))
                            .foregroundColor(colorForTime(time))  // Updated color logic
                            .padding(.leading, 10)
                            .onTapGesture {
                                showingEditReminderView = true
                            }
                    } else {
                        Text("No deadline")
                            .font(.system(size: 12, weight: .regular, design: .monospaced))
                            .foregroundColor(.gray)
                            .padding(.leading, 10)
                            .onTapGesture {
                                showingEditReminderView = true
                            }
                    }
                }

                Spacer()

                // Info Button with larger tappable area
                Button(action: {
                    showingEditReminderView = true
                }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.white)
                        .padding(10)
                        .contentShape(Circle())
                        .frame(width: 44, height: 44) // Adjust frame size as needed
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            .background(Color(red: 15/255, green: 15/255, blue: 15/255))
            .animation(.easeInOut(duration: 0.3))
            .sheet(isPresented: $showingEditReminderView, onDismiss: {
                onRefresh() // Call the refresh function when the modal is dismissed
            }) {
                EditReminderView(
                    reminder: $reminder,
                    reminderId: reminderId,
                    viewModel: viewModel,
                    taskTitle: $temporaryTitle, // Pass the binding for temporaryTitle
                    onDone: {
                        onRefresh() // Refresh when the done button is tapped in EditReminderView
                        isEditReminderClosed = true
                    }
                )
            }
            .onChange(of: reminder) { _ in
                onRefresh() // Refresh the view when reminder changes
            }
            .onChange(of: temporaryTitle) { newValue in
                reminder.title = newValue // Update the reminder's title with the new value
            }
        }
    }

    // Helper function to determine color based on the category
    private func colorForCategory(_ category: String?) -> Color {
        switch category {
        case "Blue":
            return Color.blue
        case "Green":
            return Color.green
        case "Red":
            return Color.red
        case "Yellow":
            return Color.yellow
        case "Purple":
            return Color.purple
        default:
            return Color.clear  // Return clear color or simply don't show the circle
        }
    }

    private func colorForTime(_ time: Date) -> Color {
        let now = Date()
        let calendar = Calendar.current
        let currentDay = calendar.startOfDay(for: now)
        let reminderDay = calendar.startOfDay(for: time)

        if reminderDay < currentDay {
            return .red  // Past the deadline day
        } else if time < now {
            return .orange  // Past the deadline time but on the same day
        } else {
            return .gray  // Future deadline
        }
    }

    private func startDeletionTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if isCompleted {
                withAnimation {
                    isVisible = false
                }
                onDelete()
            }
        }
    }

    private func addCheckOffTimeToReminder() {
        let db = Firestore.firestore()
        db.collection("profession_objectives").document(reminderId).updateData([
            "checkOffTime": Timestamp(date: Date())
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated with checkOffTime")
                
                // Delete any notifications for the reminder
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["reminder_\(reminderId)"])
            }
        }
    }

    private func updateReminderInFirestore(title: String? = nil, description: String? = nil, time: Date? = nil) {
        var data: [String: Any] = [:]
        if let title = title, !title.isEmpty {
            data["title"] = title
        }
        if let description = description {
            data["description"] = description
        }
        if let time = time {
            data["time"] = Timestamp(date: time)
        }
        
        let db = Firestore.firestore()
        db.collection("profession_objectives").document(reminderId).updateData(data) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated with data: \(data)")
                
                // Update the local reminder object to trigger a UI update
                if let title = title {
                    reminder.title = title
                }
                if let description = description {
                    reminder.description = description
                }
                if let time = time {
                    reminder.time = time
                }
            }
        }
    }


    private func formattedTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd, h:mm a"
        return formatter.string(from: date)
    }
}
