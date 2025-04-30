import SwiftUI
import FirebaseAuth

struct NewFieldModal: View {
    @Binding var value: Int
    @State private var inputValue: String
    var model: NewFieldModel
    var currentCategory: String?
    @State private var selectedTime: Date = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var highlightedButton: HighlightedButton? = nil
    @State private var isAutoTrackEnabled: Bool = false
    @State private var notifications: [NotificationModel] = []
    var completion: (CustomTask) -> Void
    @ObservedObject var viewModel = ObjectivesViewModel()

    enum HighlightedButton: String {
        case perDay = "per day"
        case perWeek = "per week"
    }

    @State private var selectedSegmentIndex: Int = 0

    init(value: Binding<Int>, model: NewFieldModel, currentCategory: String?, completion: @escaping (CustomTask) -> Void) {
        self._value = value
        self.model = model
        self.currentCategory = currentCategory
        self._inputValue = State(initialValue: String(value.wrappedValue))
        self.completion = completion
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                VStack {
                    Spacer()
                    TaskTitleView(model: model)

                    Spacer()

                    ValueAdjustmentView(inputValue: $inputValue, value: $value)

                    Spacer()

                    if let segmentedItems = model.segmentedItems, let explanations = model.explanations {
                        SegmentedControlView(segmentedItems: segmentedItems, explanations: explanations, selectedSegmentIndex: $selectedSegmentIndex)
                    }
                

                    HighlightButtonsView(model: model, highlightedButton: $highlightedButton)
                    Text("*Note: Weekly tasks reset on Mondays")
                        .foregroundStyle(.gray)
                        .font(.footnote)
                        .padding(3)


                    AutoTrackToggleView(model: model, isAutoTrackEnabled: $isAutoTrackEnabled)

                    Spacer()
                    

                    NavigationToNotificationSettingsView(notifications: $notifications, currentCategory: currentCategory)

                    AddObjectiveButton(
                        model: model,
                        value: value,
                        highlightedButton: highlightedButton,
                        isAutoTrackEnabled: isAutoTrackEnabled,
                        notifications: notifications,
                        selectedSegmentIndex: selectedSegmentIndex,
                        completion: completion,
                        addTaskToDatabase: addTaskToDatabase, // Pass the function here
                        currentCategory: currentCategory
                    )
                }
            }
            .ignoresSafeArea(.keyboard) // Prevent resizing when the keyboard is shown
            .navigationBarHidden(true)
        }
        .onAppear {
            inputValue = "\(value)"
        }
        .onChange(of: value) { newValue in
            inputValue = "\(newValue)"
        }
    }

    private func addTaskToDatabase(task: CustomTask) {
        let collectionName = getCollectionName(for: model.category)

        // Step 1: Add the task to Firestore
        viewModel.addTask(task: task, collection: collectionName) { taskID in
            let taskID = taskID

            // Step 2: Fetch the task ID from Firestore after adding
            viewModel.fetchTaskID(byTitle: task.title, inCollection: collectionName) { fetchedTaskID in
                if let fetchedTaskID = fetchedTaskID {
                    var updatedTask = task
                    updatedTask.id = fetchedTaskID
                    
                    // Step 3: Pass the updated task (with ID) to the completion handler
                    completion(updatedTask)
                } else {
                    print("Failed to fetch task ID for task: \(task.title)")
                }
            }
        }
    }

    private func getCollectionName(for category: String?) -> String {
        switch category {
        case "Physicality":
            return "physicality_objectives"
        case "Mindfulness":
            return "mindfulness_objectives"
        case "Productivity":
            return "profession_objectives"
        default:
            return "physicality_objectives"
        }
    }
}



// MARK: - Subviews

struct TaskTitleView: View {
    var model: NewFieldModel

    var body: some View {
        VStack {
            Text(model.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .padding(.bottom)

            Text("A goal properly set is halfway reached.")
                .foregroundColor(.white)
        }
    }
}

struct ValueAdjustmentView: View {
    @Binding var inputValue: String
    @Binding var value: Int
    @FocusState private var isInputFieldFocused: Bool

    var body: some View {
        VStack {
            HStack {
                // Decrease Button
                Button(action: {
                    if let newValue = Int(inputValue), newValue > 0 {
                        value = newValue - 1
                        inputValue = "\(value)"
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.white)
                        .font(.title2)
                }
                .padding()

                // Input Field
                TextField("Enter Value", text: $inputValue, onCommit: {
                    validateAndUpdateInput()
                })
                .keyboardType(.numberPad)
                .focused($isInputFieldFocused)
                .frame(width: 100, height: 30, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.white, lineWidth: 1))
                .padding(.all)
                .foregroundColor(.white)
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .multilineTextAlignment(.center)
                .onChange(of: inputValue) { _ in
                    if let newValue = Int(inputValue) {
                        value = newValue
                    }
                }

                // Increase Button
                Button(action: {
                    if let newValue = Int(inputValue) {
                        value = newValue + 1
                        inputValue = "\(value)"
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.white)
                        .font(.title2)
                }
                .padding()
            }

            // Dynamic Done Button
            if isInputFieldFocused {
                Button(action: {
                    validateAndUpdateInput()
                    isInputFieldFocused = false // Dismiss the keyboard
                }) {
                    Text("Done")
                        .font(.system(size: 13, weight: .bold))
                        .padding()
                        .padding(.horizontal, 5)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.top, 10)
                }
            }
        }
    }

    private func validateAndUpdateInput() {
        if let newValue = Int(inputValue), newValue >= 0 {
            value = newValue
        } else {
            inputValue = "\(value)"
        }
    }
}



struct SegmentedControlView: View {
    var segmentedItems: [String]
    var explanations: [String] // Add corresponding texts
    @Binding var selectedSegmentIndex: Int

    var body: some View {
        VStack {
            HStack(spacing: 0) {
                ForEach(0..<segmentedItems.count, id: \.self) { index in
                    segmentText(for: index)
                        .frame(width: 100)
                        .background(segmentBackground(for: index))
                        .cornerRadius(8)
                        .onTapGesture {
                            selectedSegmentIndex = index
                        }
                }
            }
            .frame(width: 300)
            .background(Color.black)
            .cornerRadius(8)
            .padding(.horizontal)
            .padding(.bottom)
            
            // Display corresponding text under the segmented control
            Text(explanations[selectedSegmentIndex])
                .foregroundColor(.gray)
                .padding(.bottom)
                .padding(.horizontal, 20)
                .font(.footnote)
        }
    }
    
    private func segmentText(for index: Int) -> some View {
        Text(segmentedItems[index])
            .foregroundColor(selectedSegmentIndex == index ? .black : .white)
            .padding()
            .font(.subheadline)
    }

    private func segmentBackground(for index: Int) -> Color {
        selectedSegmentIndex == index ? Color.white : Color(red: 18/255, green: 18/255, blue: 18/255)
    }
}

struct HighlightButtonsView: View {
    var model: NewFieldModel
    @Binding var highlightedButton: NewFieldModal.HighlightedButton?

    var body: some View {
        HStack {
            HighlightButton(title: "\(model.units)\n Per Day", isSelected: highlightedButton == .perDay) {
                toggleHighlight(.perDay)
            }

            HighlightButton(title: "\(model.units)\n Per Week", isSelected: highlightedButton == .perWeek) {
                toggleHighlight(.perWeek)
            }
        }
    }

    private func toggleHighlight(_ button: NewFieldModal.HighlightedButton) {
        if highlightedButton == button {
            highlightedButton = nil
        } else {
            highlightedButton = button
        }
    }
}

struct HighlightButton: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(isSelected ? .black : .white)
                    .multilineTextAlignment(.center)
                    .padding(.vertical)
                    .padding(.vertical, 5)
                    .padding(.all)
                    .lineLimit(2) // Set the maximum number of lines
                       .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
            }
        }
        .frame(width: 160)
        .background(isSelected ? Color.white : Color(red: 28/255, green: 28/255, blue: 30/255))  // Updated gray color to match the other buttons
        .clipShape(RoundedRectangle(cornerRadius: 8))  // Ensure consistent corner rounding
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.clear : Color.clear)  // No border when selected
        )
    }
}

struct AutoTrackToggleView: View {
    var model: NewFieldModel
    @Binding var isAutoTrackEnabled: Bool
    @State private var showToast: Bool = false  // State to control the visibility of the toast

    var body: some View {
        ZStack {
            // Main content
            VStack(alignment: .leading) {
                if model.API != "None" {
                    HStack {
                        Text("Autotrack with \(model.API)?")
                            .foregroundColor(.white)


                        Spacer()

                        Toggle("", isOn: $isAutoTrackEnabled)
                            .labelsHidden()
                            .padding(.trailing)
                        
                        // Info button to show toast
                        Button(action: {
                            withAnimation {
                                showToast.toggle()  // Toggle the visibility of the toast
                            }
                        }) {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(Color.gray)
                        }
                    }
                    .padding()
                    .frame(width: 320)
                    .background(Color(red: 18/255, green: 18/255, blue: 18/255))
                    .cornerRadius(10)
                    .padding(.top)
                }
            }

            // Toast message overlay
            if showToast {
                VStack {
                    Spacer().frame(height: 100)  // Adjust the position of the toast
                    ToastView(text: "Automatically sync '\(model.title)' progress with \(model.API) data. Only auto-tracked objectives will appear on the public leaderboard.")
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(1)  // Ensure the toast is on top of everything
                }
                .onTapGesture {
                    withAnimation {
                        showToast = false  // Dismiss the toast when tapping anywhere
                    }
                }
            }
        }
        .onTapGesture {
            if showToast {
                withAnimation {
                    showToast = false  // Dismiss the toast when tapping anywhere on the screen
                }
            }
        }
    }
}

struct ToastView: View {
    var text: String

    var body: some View {
        Text(text)
            .font(.footnote)
            .foregroundColor(.white)
            .padding()
            .background(Color.gray.opacity(0.9))
            .cornerRadius(10)
            .shadow(radius: 5)
            .frame(maxWidth: 250)  // Adjust the size as needed
    }
}

struct NavigationToNotificationSettingsView: View {
    @Binding var notifications: [NotificationModel]
    var currentCategory: String?

    var body: some View {
        NavigationLink(destination: NotificationSettingsView(notifications: $notifications, currentCategory: currentCategory, onSetNotifications: { updatedNotifications in
            notifications = updatedNotifications
        })) {
            Text("Set Notifications")
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: 300)
                .background(Color(red: 18/255, green: 18/255, blue: 18/255))
                .cornerRadius(10)
        }
    }
}

struct AddObjectiveButton: View {
    var model: NewFieldModel
    var value: Int
    var highlightedButton: NewFieldModal.HighlightedButton?
    var isAutoTrackEnabled: Bool
    var notifications: [NotificationModel]
    var selectedSegmentIndex: Int
    var completion: (CustomTask) -> Void
    var addTaskToDatabase: (CustomTask) -> Void
    var currentCategory: String?

    @State private var isButtonDisabled = false

    var body: some View {
        Button(action: {
            let newTask = CustomTask(
                title: model.title,
                progress: 0,
                goal: value,
                weeklyProgress: 0,
                monthlyProgress: 0,
                allTimeProgress: 0,
                userID: Auth.auth().currentUser?.uid ?? "default_user_id",
                notifications: notifications,
                frequency: highlightedButton?.rawValue,
                category: currentCategory,
                isAutoTrackEnabled: isAutoTrackEnabled,
                calorieStrategy: model.segmentedItems?[selectedSegmentIndex] ?? ""
            )

            // Debugging: Print the task details to ensure it's correct
            print("NewFieldModal - Task created with goal: \(newTask.goal) and category: \(newTask.category ?? "None")")

            addTaskToDatabase(newTask)
            completion(newTask)  // Pass the task back to AddObjectiveModal

            // Check if auto-tracking is enabled, and if so, update progress
            if isAutoTrackEnabled {
                // Retrieve the fetching functions from APIDict based on the task title
                if let fetchers = APIDict[newTask.title] {
                    // Call the updateProgressForAllTimeFrames function with the fetchers from APIDict
                    HealthKitManager.shared.updateProgressForAllTimeFrames(
                        dailyFetcher: fetchers.daily,
                        weeklyFetcher: fetchers.weekly,
                        monthlyFetcher: fetchers.monthly,
                        title: newTask.title // Pass the title of the new task
                    )
                } else {
                    print("No matching fetchers found in APIDict for title: \(newTask.title)")
                }
            }
        }) {
            Text("Add Objective")
        }
        .padding()
        .frame(maxWidth: 300.0)
        .background(Color.white)
        .cornerRadius(8)
        .foregroundColor(.black)
        .disabled(isButtonDisabled || highlightedButton == nil || value <= 0) // Add the condition for value > 0
        .opacity(isButtonDisabled || highlightedButton == nil || value <= 0 ? 0.5 : 1.0)
        .onAppear {
            // Re-enable the button when the view appears, if needed
            isButtonDisabled = false
        }
    }
}
