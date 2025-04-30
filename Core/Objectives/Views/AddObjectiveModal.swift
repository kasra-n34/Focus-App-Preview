import SwiftUI
import FirebaseAuth

struct AddObjectiveModal: View {
    @State private var showModal: Bool = false
    @State private var selectedModel: NewFieldModel?
    @State private var currentCategory: String? = nil
    @State private var currentValue: Int = 0
    @State private var goalValue: Int = 0
    @State private var reminders: [ProfessionObjective] = []
    @Environment(\.presentationMode) var presentationMode
    var onReminderAdded: ((ProfessionObjective) -> Void)?
    var onTaskAdded: ((CustomTask, String) -> Void)?
    @ObservedObject var viewModel = ObjectivesViewModel()
    
    @Binding var categories: [Category]
    
    let AddObjectiveButtonModels = [
        AddObjectiveButtonModel(title: "Track Workouts", imageName: "dumbbell.fill", category: "Physicality", units: "Workouts", API: "Apple Watch"),
        AddObjectiveButtonModel(title: "Track Calories", imageName: "takeoutbag.and.cup.and.straw.fill", category: "Physicality", units: "Calories", API: "None", segmentedItems: ["Maintain", "Bulk", "Cut"], explanations: ["Reaching any amount +/- 250 calories of your goal will improve your rating.","Reaching any amount above the calorie goal you set will improve your rating.","Reaching any amount below the calorie goal you set (but above 1500 calories) will improve your rating."]),
        AddObjectiveButtonModel(title: "Track Steps", imageName: "figure.walk", category: "Physicality", units: "Steps", API: "Health"),
        AddObjectiveButtonModel(title: "Track Runs", imageName: "figure.run", category: "Physicality", units: "Kilometers", API: "Health"),
        AddObjectiveButtonModel(title: "Track Journaling", imageName: "book.closed.fill", category: "Mindfulness", units: "Entries", API: "Focus"),
        AddObjectiveButtonModel(title: "Track Prayers", imageName: "hands.and.sparkles.fill", category: "Mindfulness", units: "Prayers", API: "None"),
        AddObjectiveButtonModel(title: "Track Stair Workouts", imageName: "figure.stair.stepper", category: "Physicality", units: "Workouts", API: "Apple Watch"),
        AddObjectiveButtonModel(title: "Track Calories Burned", imageName: "flame.fill", category: "Physicality", units: "Calories", API: "Health"),
        AddObjectiveButtonModel(title: "Track Sleep", imageName: "bed.double.fill", category: "Mindfulness", units: "Hours", API: "Apple Watch"),
        AddObjectiveButtonModel(title: "Track Meditation", imageName: "figure.mind.and.body", category: "Mindfulness", units: "Sessions", API: "None"),
        AddObjectiveButtonModel(title: "Track Reading", imageName: "book.fill", category: "Mindfulness", units: "Pages", API: "None"),
        AddObjectiveButtonModel(title: "Track Protein", imageName: "bolt.fill", category: "Physicality", units: "Grams", API: "None"),
        AddObjectiveButtonModel(title: "Track Sports", imageName: "figure.basketball", category: "Physicality", units: "Hours", API: "Apple Watch"),
        AddObjectiveButtonModel(title: "Track Cycling", imageName: "figure.outdoor.cycle", category: "Physicality", units: "Kilometers", API: "Health"),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack {
                    
                    HStack {
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.gray)
                                .padding(.top)
                                .padding(.horizontal)
                        }
                        Spacer()
                    }
                    .padding(.leading)
                    .padding(.top, 2)

                    
                    Text("Add an Objective")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.leading)
                   
                    
                    HStack {
                        CategoryButton(text: "Physicality", selectedCategory: $currentCategory)
                        CategoryButton(text: "Mindfulness", selectedCategory: $currentCategory)
                        CategoryButton(text: "Productivity", selectedCategory: $currentCategory)
                    }
                    .padding(.bottom)

                    if currentCategory == "Productivity" {
                        CustomTaskView(reminders: $reminders, onReminderAdded: onReminderAdded, viewModel: viewModel)
                    } else {
                        ScrollView {
                            ForEach(AddObjectiveButtonModels.filter { button in
                                currentCategory == nil || button.category == currentCategory
                            }, id: \.title) { button in
                                let isTaskExists = viewModel.taskExists(withTitle: button.title)
                                NavigationLink(destination: NewFieldModal(
                                    value: $currentValue,
                                    model: NewFieldModel(title: button.title, units: button.units, API: button.API, category: button.category, segmentedItems: button.segmentedItems, explanations: button.explanations),
                                    currentCategory: currentCategory,
                                    completion: { updatedTask in
                                        // Pass the updated task with taskID back to ObjectivesView
                                        onTaskAdded?(updatedTask, button.category)
                                        // Add the task directly to the corresponding category
                                        if let categoryIndex = categories.firstIndex(where: { $0.title == button.category }) {
                                            categories[categoryIndex].tasks.append(updatedTask)
                                        }
                                        // Dismiss the modal
                                        self.presentationMode.wrappedValue.dismiss()
                                    }
                                )) {
                                    AddObjectiveListButton2(model: button, isDisabled: isTaskExists)
                                }
                                .disabled(isTaskExists)
                            }
                        }
                    }
                    Spacer()
                }
            }
        }
        .onAppear {
            viewModel.fetchTasks() {} // Provide an empty closure
        }
    }
}


struct AddObjectiveListButton2: View {
    var model: AddObjectiveButtonModel
    var isDisabled: Bool

    var body: some View {
        HStack {
            Image(systemName: model.imageName)
                .foregroundColor(isDisabled ? .gray : .white)
            VStack(alignment: .leading) {
                Text(model.title)
                    .foregroundColor(isDisabled ? .gray : .white)
                    .font(.headline)
                    .padding(.bottom, 1)
                if !model.units.isEmpty {
                    Text(model.units)
                        .foregroundColor(isDisabled ? .gray : .gray)
                        .font(.system(size: 13, weight: .medium, design: .monospaced)) // Monospaced for numbers
                        .padding(.leading, 1)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(isDisabled ? .gray : .white)
        }
        .padding()
        .background(
            Color(red: 18/255, green: 18/255, blue: 18/255)
                .cornerRadius(10) // Apply corner radius to the background itself
        )
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}

struct CustomTaskView: View {
    @State private var taskTitle: String = ""
    @State private var taskDescription: String = ""
    @State private var deadline: Date? = nil
    @Binding var reminders: [ProfessionObjective]
    var onReminderAdded: ((ProfessionObjective) -> Void)?
    @ObservedObject var viewModel: ObjectivesViewModel
    @State private var isDeadlineEnabled: Bool = false
    @State private var isColorCodeEnabled: Bool = false // New state for enabling/disabling color code

    @State private var selectedCategory: String? = nil

    @StateObject private var professionObjectiveModel: ProfessionObjectiveModel
    @Environment(\.presentationMode) var presentationMode

    init(reminders: Binding<[ProfessionObjective]>, onReminderAdded: ((ProfessionObjective) -> Void)?, viewModel: ObjectivesViewModel) {
        self._reminders = reminders
        self.onReminderAdded = onReminderAdded
        self.viewModel = viewModel
        _professionObjectiveModel = StateObject(wrappedValue: ProfessionObjectiveModel(reminders: reminders, onReminderAdded: onReminderAdded, viewModel: viewModel))
    }

    var body: some View {
        VStack(alignment: .leading) {
            
            GeometryReader { geometry in
                VStack {
                    ScrollView {
                        VStack(alignment: .leading) {
                            
                            // Task Title and Description
                            CustomTextField2("Enter Task Title", text: $professionObjectiveModel.taskTitle)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 5)
                            CustomTextEditor2(text: $professionObjectiveModel.taskDescription)
                                .padding(.horizontal, 20)
                                .frame(height: geometry.size.height / 3)

                            // Set Deadline Section
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 10)
                                
                                VStack(alignment: .leading){
                                   Text("Set Notification?")
                                        .foregroundStyle(.white)
                                        .font(.headline)
                                        .padding(.bottom, 2)
                                    
                                    Text("If you set a notification, check it off by the end of that day for more points.")
                                        .foregroundStyle(.gray)
                                        .font(.caption)
                                        .fixedSize(horizontal: false, vertical: true) // Allow text to wrap
                                }
                           
                                Toggle("", isOn: $isDeadlineEnabled)
                                    .labelsHidden()
                                    .padding(.horizontal, 10)
                                    .alignmentGuide(.top) { _ in 0 } // Align toggle to top
                                    .tint(.blue) // Set the toggle color to blue when on
                            }
                            .padding()
                            .background(Color(red: 18/255, green: 18/255, blue: 18/255))
                            .cornerRadius(10)
                            .padding(.horizontal, 20)

                            if isDeadlineEnabled {
                                HStack {
                                    Spacer()
                                    DatePicker("", selection: Binding(
                                        get: { professionObjectiveModel.deadline ?? Date() },
                                        set: { professionObjectiveModel.deadline = $0 }
                                    ), displayedComponents: [.date, .hourAndMinute])
                                    .labelsHidden()
                                    .padding()
                                    .padding(.horizontal, 50)
                                    .background(Color(red: 18/255, green: 18/255, blue: 18/255))
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 10)
                            }

                            // Color Code Section
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
                                    .padding(.horizontal, 10)
                                    .alignmentGuide(.top) { _ in 0 } // Align toggle to top
                                    .tint(.blue) // Set the toggle color to blue when on
                            }
                            .padding()
                            .background(Color(red: 18/255, green: 18/255, blue: 18/255))
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                            
                            // Show color buttons only when color coding is enabled
                            if isColorCodeEnabled {
                                HStack {
                                    Spacer()
                                    CategorySelectionButton(color: .black, title: "No Category", selectedCategory: $selectedCategory, icon: "xmark")
                                        .overlay(
                                            Circle()
                                                .stroke(Color.gray, lineWidth: 2) // Circular border
                                        )
                                    CategorySelectionButton(color: .blue, title: "Blue", selectedCategory: $selectedCategory)
                                    CategorySelectionButton(color: .green, title: "Green", selectedCategory: $selectedCategory)
                                    CategorySelectionButton(color: .red, title: "Red", selectedCategory: $selectedCategory)
                                    CategorySelectionButton(color: .yellow, title: "Gold", selectedCategory: $selectedCategory)
                                    CategorySelectionButton(color: .purple, title: "Purple", selectedCategory: $selectedCategory)
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 10)
                                .padding(.top, 10) // Added spacing above the buttons
                            }
                            
                            Spacer()

                            // Add Task Button
                            Button(action: {
                                let reminder = ProfessionObjective(
                                    title: professionObjectiveModel.taskTitle,
                                    description: professionObjectiveModel.taskDescription,
                                    time: professionObjectiveModel.deadline,
                                    userID: Auth.auth().currentUser?.uid ?? "",
                                    category: selectedCategory // Set the selected category
                                )
                                professionObjectiveModel.addReminder(reminder: reminder)
                                presentationMode.wrappedValue.dismiss() // Close the modal
                            }) {
                                Text("Add Task")
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                                    .padding(.horizontal, 20)
                            }
                            .padding(.bottom, 20)
                            
                            Spacer()
                            Spacer()
                            Spacer()
                        }
                    }
                }
            }
            Spacer()
        }
        .padding(.top)
        .background(Color.black)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Button Component for Category Selection
struct CategorySelectionButton: View {
    var color: Color
    var title: String
    @Binding var selectedCategory: String?
    var icon: String? = nil  // Optional icon for "No Category"

    var body: some View {
        Button(action: {
            selectedCategory = (selectedCategory == title ? nil : title)
        }) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 30, height: 30)
                    .overlay(
                        selectedCategory == title ? Circle().stroke(Color.white, lineWidth: 2) : nil
                    )
                
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(.white)
                        .font(.caption)
                }
            }
        }
        .padding(.horizontal, 5)
    }
}



struct CustomTextField2: View {
    var placeholder: String
    @Binding var text: String

    init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }

    var body: some View {
        HStack {
            Spacer() // Add spacer to push the text to the center
            TextFieldWithToolbar(placeholder: placeholder, fontSize: 22, text: $text)
                .font(.title2)
                .background(Color.black) // Set background to black
                .foregroundColor(.white) // Text color
                .multilineTextAlignment(.center) // Center align text within the TextField
            Spacer() // Add spacer to ensure centering
        }
        .overlay(
            Rectangle() // Draw a line instead of a full border
                .frame(height: 2) // Line height
                .foregroundColor(Color(red: 58/255, green: 58/255, blue: 58/255)) // Dark grey color with slight opacity
                .padding(.top, 35), // Position the underline at the bottom
            alignment: .bottom // Align the line to the bottom of the TextField
        )
        .padding(.bottom, 15) // Add padding to the bottom to make space for the underline
    }
}

struct CustomTextEditor2: View {
    @Binding var text: String
    var placeholder: String = "Enter notes for your task here..." // Placeholder text

    var body: some View {
        ZStack(alignment: .topLeading) {
            
            TextFieldWithToolbar(placeholder: placeholder, fontSize: 14, text: $text)
                .padding(4) // Padding inside the text editor
                .background(Color.black) // Set background to black
                .overlay(
                    RoundedRectangle(cornerRadius: 10) // Rounded corners
                        .stroke(Color(red: 58/255, green: 58/255, blue: 58/255), lineWidth: 3) // Dark grey border
                )
                .cornerRadius(10) // Ensure corners are rounded
        }
    }
}

struct TextFieldWithToolbar: UIViewRepresentable {
    var placeholder: String
    var fontSize: Int
    @Binding var text: String

    // Coordinator class to handle UITextField delegate functions
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: TextFieldWithToolbar

        init(_ parent: TextFieldWithToolbar) {
            self.parent = parent
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            // Update the binding with the current text
            parent.text = textField.text ?? ""
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            // Dismiss the keyboard when 'Done' is pressed
            textField.resignFirstResponder()
            return true
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // Custom UITextField class to allow for top padding
    class PaddedTextField: UITextField {
        var topPadding: CGFloat = 10 // Adjust this value for more/less top padding

        override func textRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: UIEdgeInsets(top: topPadding, left: 15, bottom: 0, right: 15))
        }

        override func editingRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: UIEdgeInsets(top: topPadding, left: 15, bottom: 0, right: 15))
        }
    }

    func makeUIView(context: Context) -> PaddedTextField {
        let textField = PaddedTextField()
        textField.placeholder = placeholder
        textField.text = text
        textField.delegate = context.coordinator
        textField.backgroundColor = UIColor.black
        textField.textColor = .white
        textField.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
        textField.layer.cornerRadius = 10
        textField.layer.masksToBounds = true
        textField.topPadding = 10 // Adjust top padding as needed

        // Add padding to the left side using a leftView
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 15))
        textField.leftView = paddingView
        textField.leftViewMode = .always

        // Set text alignment to top-left
        textField.contentVerticalAlignment = .top
        textField.textAlignment = .left

        // Toolbar for the keyboard with a 'Done' button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: textField, action: #selector(textField.resignFirstResponder))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolbar.items = [flexibleSpace, doneButton]
        textField.inputAccessoryView = toolbar

        return textField
    }

    func updateUIView(_ uiView: PaddedTextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }
}




struct CategoryButton: View {
    var text: String
    @Binding var selectedCategory: String?

    var body: some View {
        Button(action: {
            selectedCategory = (selectedCategory == text ? nil : text)
        }) {
            Text(text)
                .font(.subheadline)
                .foregroundColor(selectedCategory == text ? .blue : .white)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
        }
    }
}

