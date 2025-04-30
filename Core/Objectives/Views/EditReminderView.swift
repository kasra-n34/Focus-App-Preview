import SwiftUI
import FirebaseFirestore

struct EditReminderView: View {
    @Binding var taskTitle: String
    @State private var taskDescription: String
    @State private var deadline: Date? // Optional deadline
    @State private var isDeadlineEnabled: Bool // New state for enabling/disabling deadline
    @State private var isColorCodeEnabled: Bool = false // New state for enabling/disabling color code
    @Binding var reminder: ProfessionObjective
    
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ObjectivesViewModel
    var onDone: () -> Void
    
    // Add a property to hold the reminder ID
    private let reminderId: String
    
    // Color categories for the reminder
    private let colors = ["Blue", "Green", "Red", "Yellow", "Purple"]
    private let colorMap: [String: Color] = [
        "Blue": Color.blue,
        "Green": Color.green,
        "Red": Color.red,
        "Yellow": Color.yellow,
        "Purple": Color.purple
    ]

    @State private var selectedColor: String? // Track selected color
    
    init(reminder: Binding<ProfessionObjective>, reminderId: String, viewModel: ObjectivesViewModel, taskTitle: Binding<String>, onDone: @escaping () -> Void) {
        self._reminder = reminder
        self.reminderId = reminderId // Store the reminder ID
        self._taskTitle = taskTitle
        self._taskDescription = State(initialValue: reminder.wrappedValue.description)
        self._deadline = State(initialValue: reminder.wrappedValue.time) // Handle as optional
        self._isDeadlineEnabled = State(initialValue: reminder.wrappedValue.time != nil) // Initialize based on whether a deadline exists

        // Initialize color code states based on existing category
        if let existingCategory = reminder.wrappedValue.category, !existingCategory.isEmpty {
            self._isColorCodeEnabled = State(initialValue: true)
            self._selectedColor = State(initialValue: existingCategory)
        } else {
            self._isColorCodeEnabled = State(initialValue: false)
            self._selectedColor = State(initialValue: nil)
        }

        self.viewModel = viewModel
        self.onDone = onDone
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                // Handle at the top
                ZStack {
                    Capsule()
                        .fill(Color(red: 58/255, green: 58/255, blue: 58/255).opacity(0.5))
                        .frame(width: 110, height: 10)
                        .padding(.top, 8)
                    Capsule()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 100, height: 4)
                        .padding(.top, 8)
                }

                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                

                CustomTextField2("Enter Task Title", text: $taskTitle)
                    .onChange(of: taskTitle) { newValue in
                        reminder.title = newValue
                        updateReminderInFirestore(reminderId: reminderId, title: newValue)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 10)
                    .frame(height: 40)

                CustomTextEditor2(text: $taskDescription)
                    .padding(.horizontal, 20)
                    .frame(height: 200)
                    .onChange(of: taskDescription) { newValue in
                        reminder.description = newValue
                        updateReminderInFirestore(reminderId: reminderId, description: newValue)
                    }

                HStack {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.blue)
                        .padding(.horizontal, 10)
                    
                    VStack(alignment: .leading){
                       Text("Set Notification")
                            .foregroundStyle(.white)
                            .font(.headline)
                            .padding(.bottom, 2)
                        
                        Text("If you set a notification, check it off by the end of that day for more points.")
                            .foregroundStyle(.gray)
                            .font(.caption)
                            .fixedSize(horizontal: false, vertical: true) // Allow text to wrap
                    }
                    
                    Spacer()
               
                    Toggle("", isOn: $isDeadlineEnabled)
                        .labelsHidden()
                        .padding(.horizontal, 20)
                        .alignmentGuide(.top) { _ in 0 } // Align toggle to top
                        .tint(.blue) // Set the toggle color to blue when on
                }
                .padding()
                .background(Color(red: 18/255, green: 18/255, blue: 18/255))
                .cornerRadius(10)
                .padding(.horizontal, 20)

                if isDeadlineEnabled {
                    HStack {
                
                        DatePicker("", selection: Binding(
                            get: { deadline ?? Date() },
                            set: { deadline = $0 }
                        ), displayedComponents: [.date, .hourAndMinute])
                        .labelsHidden()
                        .padding()
                        .padding(.horizontal, 30)
                        .background(Color(red: 18/255, green: 18/255, blue: 18/255))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .font(.subheadline)
                  
                    }
                    .onChange(of: deadline) { newValue in
                        reminder.time = newValue
                        updateReminderInFirestore(reminderId: reminderId, time: newValue)
                    }
                    .padding(.horizontal, 20)
                }
                
                // Color code section
                HStack {
                    Image(systemName: "paintbrush.fill")
                        .foregroundColor(.blue)
                        .padding(.horizontal, 10)
                    
                    VStack(alignment: .leading){
                       Text("Color Code")
                            .foregroundStyle(.white)
                            .font(.headline)
                            .padding(.bottom, 2)
                        
                        Text("Categorize by color to allow for sorting your tasks.")
                            .foregroundStyle(.gray)
                            .font(.caption)
                            .fixedSize(horizontal: false, vertical: true) // Allow text to wrap
                    }
                    
                    Spacer()
               
                    Toggle("", isOn: $isColorCodeEnabled)
                        .labelsHidden()
                        .padding(.horizontal, 20)
                        .alignmentGuide(.top) { _ in 0 } // Align toggle to top
                        .tint(.blue) // Set the toggle color to blue when on
                }
                .padding()
                .background(Color(red: 18/255, green: 18/255, blue: 18/255))
                .cornerRadius(10)
                .padding(.horizontal, 20)

                if isColorCodeEnabled {
                    colorSelectionView()
                        .padding(.horizontal, 50)
                        .padding(.vertical, 10)
                }

                Button(action: saveChanges) {
                    Text("Done")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 18/255, green: 18/255, blue: 18/255))
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                }
                
                
            }
            .padding(.top)
        }
        .background(Color.black)
        .ignoresSafeArea(.keyboard) // Prevents keyboard from pushing the view up
        .navigationBarTitleDisplayMode(.inline)
        .presentationDetents([.fraction(0.9)])
        .onDisappear {
                saveChanges()
            }
    }

    private func saveChanges() {
        if !isDeadlineEnabled {
            reminder.time = nil
            updateReminderInFirestore(reminderId: reminderId, time: nil)
        }
        onDone()
        presentationMode.wrappedValue.dismiss()
    }

    private func updateReminderInFirestore(reminderId: String, title: String? = nil, description: String? = nil, time: Date? = nil, category: String? = nil, deleteCategory: Bool = false) {
        var data: [String: Any] = [:]
        
        if let title = title {
            data["title"] = title.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        if let description = description {
            data["description"] = description.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        if let time = time {
            data["time"] = Timestamp(date: time)
        } else {
            data["time"] = FieldValue.delete()
        }
        
        if deleteCategory {
            data["category"] = FieldValue.delete() // Delete the category field
        } else if let category = category {
            data["category"] = category
        }

        let db = Firestore.firestore()
        
        db.collection("profession_objectives").document(reminderId).updateData(data) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated with data: \(data)")
                self.scheduleNotification(title: title, time: time)
            }
        }
    }

    private func colorSelectionView() -> some View {
        HStack(spacing: 15) {
            noColorButton()
            ForEach(colors, id: \.self) { color in
                colorButton(category: color, color: colorMap[color] ?? .gray)
            }
        }
    }

    private func colorButton(category: String, color: Color) -> some View {
        Button(action: {
            selectedColor = category
            reminder.category = category
            updateReminderInFirestore(reminderId: reminderId, category: category)
        }) {
            Circle()
                .fill(color)
                .frame(width: 30, height: 30)
                .overlay(
                    Circle().stroke(Color.white, lineWidth: selectedColor == category ? 2 : 0)
                )
        }
    }

    private func noColorButton() -> some View {
        Button(action: {
            selectedColor = nil
            reminder.category = nil
            updateReminderInFirestore(reminderId: reminderId, deleteCategory: true)
        }) {
            Circle()
                .stroke(Color.gray, lineWidth: 2)
                .frame(width: 30, height: 30)
                .overlay(
                    Text("x")
                        .foregroundColor(.gray)
                        .font(.system(size: 14, weight: .bold))
                )
        }
    }


    private func scheduleNotification(title: String? = nil, time: Date? = nil) {
        guard let deadline = time else { return }
        let content = UNMutableNotificationContent()
        content.title = "Reminder: \(title ?? "Profession Objective")"
        content.body = "Your task deadline is here!"
        content.sound = UNNotificationSound.default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: deadline)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let identifier = "reminder_\(reminderId)"
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
           if let error = error {
               print("Error scheduling notification: \(error.localizedDescription)")
           } else {
               print("Notification scheduled successfully for \(reminderId) at \(deadline)")
           }
       }
    }
}


/*

struct EditReminderView_Previews: PreviewProvider {
    static var previews: some View {
        EditReminderView(
            reminder: .constant(ProfessionObjective(
                title: "Sample Task",
                description: "This is a sample task description.",
                time: Date(),
                userID: "sampleUserID",
                checkOffTime: nil,
                creationTime: Date(),
                category: "Blue"
            )),
            reminderId: "sampleReminderID",
            viewModel: ObjectivesViewModel(),
            onDone: {}
        )
        .preferredColorScheme(.dark) // Optional: Set to dark mode for consistency with background
    }
}
*/
