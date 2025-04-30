import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// Sample categories with LinearGradient colors
let focusPillars: [Category] = [
    Category(
        title: "Physicality",
        color: LinearGradient(
            gradient: Gradient(colors: [Color.orange, Color.red]),
            startPoint: .leading,
            endPoint: .trailing
        ),
        tasks: []
    ),
    Category(
        title: "Mindfulness",
        color: LinearGradient(
            gradient: Gradient(colors: [Color.orange, Color.green]),
            startPoint: .leading,
            endPoint: .trailing
        ),
        tasks: []
    ),
    Category(
        title: "Productivity",
        color: LinearGradient(
            gradient: Gradient(colors: [Color.blue, Color.purple]),
            startPoint: .leading,
            endPoint: .trailing
        ),
        tasks: []
    )
]

class CategoryViewModel: ObservableObject {
    static let shared = CategoryViewModel()
    
    @Published var categories: [Category] = focusPillars
    
    private init() {

    }
}


struct ObjectivesView: View {
    @StateObject private var categoryViewModel = CategoryViewModel.shared
    @StateObject private var professionObjectiveModel = ProfessionObjectiveModel(reminders: .constant([]), onReminderAdded: nil, viewModel: ObjectivesViewModel())
    
    @State private var showingEditModal = false
    @State private var showingAddObjectiveModal = false
    @State private var selectedTaskIndex: Int?
    @State private var selectedCategoryIndex: Int?
    @State private var selectedCategoryGradient: LinearGradient = LinearGradient(
        gradient: Gradient(colors: [.clear, .clear]),
        startPoint: .leading,
        endPoint: .trailing
    )
    @State private var reminders: [ProfessionObjective] = []
    @State private var selectedReminder: ProfessionObjective?
    @State private var selectedColorCategory: String? = nil // Tracks selected color category
    @State private var isSlidingMenuOpen = false // Tracks the state of the sliding menu
    @State private var didEditReminderViewJustClose = false
    @State private var isEditReminderClosed = false
    
    @EnvironmentObject private var viewModel: ObjectivesViewModel
    @State private var isDataFresh = false  // Tracks if data has been fetched and is fresh

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                VStack(alignment: .leading, spacing: 10) {
                    headerView()
                    objectivesListView(isEditReminderClosed: $isEditReminderClosed)
                }
                .background(Color.black.edgesIgnoringSafeArea(.all))

                floatingAddButton()
            }
            .sheet(isPresented: $showingAddObjectiveModal, onDismiss: {
                // Trigger a refresh when the modal is dismissed
                refreshTasks(forceRefresh: true)
                
            }) {
                AddObjectiveModal(
                    onTaskAdded: { newTask, categoryTitle in
                        addTaskToCategory(newTask: newTask)
                    },
                    categories: $categoryViewModel.categories  // Pass the binding here
                )
            }
            .onAppear {
                // Fetch data only on the first appearance
                if !viewModel.hasAppearedOnce {
                    fetchAndUpdateTasks()
                    viewModel.hasAppearedOnce = true
                }
            }
            // Use onChange to detect when isEditReminderClosed becomes true
            .onChange(of: isEditReminderClosed) { newValue in
                if newValue {
                    // Perform the refresh action
                    viewModel.fetchProfessionObjectives {
                        self.reminders = viewModel.professionReminders
                    }
                    // Reset the flag
                    isEditReminderClosed = false
                }
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }

    private func addTaskToCategory(newTask: CustomTask) {
        if let categoryIndex = categoryViewModel.categories.firstIndex(where: { $0.title == newTask.category }) {
            if !categoryViewModel.categories[categoryIndex].tasks.contains(where: { $0.id == newTask.id || $0.title == newTask.title }) {
                categoryViewModel.categories[categoryIndex].tasks.append(newTask)
                categoryViewModel.objectWillChange.send()
            }
        }
    }

    private func fetchAndUpdateTasks() {
        viewModel.fetchAll {
            DispatchQueue.main.async {
                self.reminders = self.viewModel.professionReminders
                self.updateCategoryTasks()
                self.isDataFresh = true
            }
        }
    }

    private func refreshTasks(forceRefresh: Bool = false) {
        if forceRefresh || !isDataFresh {
            fetchAndUpdateTasks()
        }
    }

    private func updateCategoryTasks() {
        if let physicalityIndex = categoryViewModel.categories.firstIndex(where: { $0.title == "Physicality" }) {
            categoryViewModel.categories[physicalityIndex].tasks = viewModel.physicalityTasks
        }
        
        if let mindfulnessIndex = categoryViewModel.categories.firstIndex(where: { $0.title == "Mindfulness" }) {
            categoryViewModel.categories[mindfulnessIndex].tasks = viewModel.mindfulnessTasks
        }

        categoryViewModel.objectWillChange.send()
    }

    private func headerView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(Date(), formatter: dateFormatter)
                .font(.subheadline)
                .foregroundColor(.gray)
                .fontWeight(.semibold)
                .padding([.leading], 25.0)
                .padding(.top, 20.0)

            Text("Objectives")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding([.leading], 25.0)
                .padding(.bottom, 15)
        }
    }

    private func objectivesListView(isEditReminderClosed: Binding<Bool>) -> some View {
        ScrollView {
            VStack(spacing: 15) {
                ForEach($categoryViewModel.categories, id: \.id) { $category in
                    if category.title == "Productivity" {
                        ProfessionSection(
                            category: $category,
                            reminders: $reminders, // Pass the full reminders binding
                            showingEditModal: $showingEditModal, // Add this argument
                            selectedTaskIndex: $selectedTaskIndex, // Pass selected task index
                            selectedCategoryIndex: $selectedCategoryIndex, // Pass selected category index
                            selectedCategoryGradient: $selectedCategoryGradient, // Pass gradient
                            ProfessionModel: professionObjectiveModel,
                            viewModel: viewModel,
                            categories: $categoryViewModel.categories, // Pass the categories binding
                            refreshTasks: refreshTasks,  // Pass the refreshTasks method
                            isEditReminderClosed: isEditReminderClosed // Correctly pass the binding
                        )
                    } else {
                        PhysicalityandMindfulnessSection(
                            category: $category,
                            showingEditModal: $showingEditModal, // Add this argument
                            selectedTaskIndex: $selectedTaskIndex,
                            selectedCategoryIndex: $selectedCategoryIndex,
                            selectedCategoryGradient: $selectedCategoryGradient,
                            categories: $categoryViewModel.categories, // Pass the categories binding
                            refreshTasks: refreshTasks  // Pass the refreshTasks method
                        )
                    }
                }
            }
            .padding(.horizontal, 10)
        }
        .background(Color.black)
    }

    private func colorButton(_ category: String, colors: [Color]) -> some View {
        Button(action: {
            selectedColorCategory = category
            isSlidingMenuOpen = false
        }) {
            LinearGradient(gradient: Gradient(colors: colors), startPoint: .leading, endPoint: .trailing)
                .frame(width: 40, height: 40)
                .cornerRadius(8)
        }
    }

    private func floatingAddButton() -> some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    self.showingAddObjectiveModal = true
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(.white))
                            .opacity(0.85)
                            .frame(width: 55, height: 55)
                            .shadow(color: Color.white.opacity(0.45), radius: 10, x: 0, y: 0)

                        Image(systemName: "plus")
                            .font(.system(size: 28))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                }
                .padding(.trailing, 25)
                .padding(.top, 25)
            }
            Spacer()
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter
    }
}




struct PhysicalityandMindfulnessSection: View {
    @Binding var category: Category
    @Binding var showingEditModal: Bool
    @Binding var selectedTaskIndex: Int?
    @Binding var selectedCategoryIndex: Int?
    @Binding var selectedCategoryGradient: LinearGradient
    @Binding var categories: [Category]
    var refreshTasks: (Bool) -> Void  // Accept the refreshTasks method as a closure

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(category.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding([.top, .bottom], 12)
                    .padding(.leading, 5)
                    .shadow(color: Color.black.opacity(0.85), radius: 10, x: 0, y: 0)

                Spacer()
            }
            .padding(.horizontal, 10)

            if category.tasks.isEmpty {
                PlaceholderCardView()
            } else {
                ForEach(category.tasks.indices, id: \.self) { index in
                    TaskRow(
                        task: $category.tasks[index],  // Binding to the correct task
                        categoryGradient: category.color,
                        editAction: {
                            self.selectedTaskIndex = index
                            self.selectedCategoryIndex = categories.firstIndex(where: { $0.id == category.id })
                            self.selectedCategoryGradient = category.color // Set the gradient for the selected task
                            self.showingEditModal = true
                        }
                    )
                    .padding(.vertical, 0)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color(red: 15/255, green: 15/255, blue: 15/255))
        .cornerRadius(12)
        .padding(.vertical, 5)
        .padding(.horizontal, 15)
        .sheet(isPresented: $showingEditModal) {
            if let selectedTaskIndex = selectedTaskIndex,
               let selectedCategoryIndex = selectedCategoryIndex,
               selectedTaskIndex < categories[selectedCategoryIndex].tasks.count {
                EditObjectiveModal(
                    task: $categories[selectedCategoryIndex].tasks[selectedTaskIndex],
                    categoryGradient: selectedCategoryGradient,
                    collection: determineCollection(for: categories[selectedCategoryIndex].tasks[selectedTaskIndex]),
                    deleteAction: {
                        categories[selectedCategoryIndex].tasks.remove(at: selectedTaskIndex)
                        showingEditModal = false
                    }
                )
                .background(Color.black.edgesIgnoringSafeArea(.all))
            } else {
                // In case indices are out of bounds or missing, display an empty view
                EmptyView()
            }
        }
    }

    private func determineCollection(for task: CustomTask) -> String {
        if categories.first(where: { $0.tasks.contains(where: { $0.id == task.id }) })?.title == "Physicality" {
            return "physicality_objectives"
        } else {
            return "mindfulness_objectives"
        }
    }
}


struct ProfessionSection: View {
    @Binding var category: Category
    @Binding var reminders: [ProfessionObjective]
    @Binding var showingEditModal: Bool
    @Binding var selectedTaskIndex: Int?
    @Binding var selectedCategoryIndex: Int?
    @Binding var selectedCategoryGradient: LinearGradient
    @ObservedObject var ProfessionModel: ProfessionObjectiveModel
    @ObservedObject var viewModel: ObjectivesViewModel
    @Binding var categories: [Category]
    var refreshTasks: (Bool) -> Void

    // Selected color category to filter tasks
    @State private var selectedColorCategory: String? = nil
    @State private var isTodayFilterActive: Bool = false  // State to track if the Today filter is active
    @State private var showColorCategories: Bool = false
    @Binding var isEditReminderClosed: Bool

    var body: some View {
        VStack(spacing: 0) {
            header

            // Conditionally show the color selection view
            if showColorCategories {
                colorSelectionView()
            }

            if filteredReminders.isEmpty {
                addReminderPrompt
            } else {
                remindersList
                addReminderPrompt
            }
        }
        .onAppear {
            checkAndShowColorCategories()
        }
        // Trigger check whenever isEditReminderClosed changes
        .onChange(of: isEditReminderClosed) { _ in
            checkAndShowColorCategories()
        }
        .frame(maxWidth: .infinity)
        .background(Color(red: 15/255, green: 15/255, blue: 15/255))
        .cornerRadius(12)
        .padding(.horizontal, 15)
        .padding(.vertical, 5)
        
    }

    // Helper function to check if color categories should be shown
    private func checkAndShowColorCategories() {
        ProfessionModel.checkIfCategoriesExist { hasCategories in
            self.showColorCategories = hasCategories
        }
    }

    private var header: some View {
        HStack {
            Text(category.title)
                .font(.headline)
                .foregroundColor(.white)
                .padding([.top, .bottom], 12)
                .padding(.leading, 5)
                .shadow(color: Color.black.opacity(0.95), radius: 10, x: 0, y: 0)

            Spacer()

            // Today Button
            Button(action: {
                isTodayFilterActive.toggle()
                refreshTasks(true) // Refresh tasks to apply the filter
            }) {
                Text("Today")
                    .foregroundColor(isTodayFilterActive ? .blue : .white)
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(isTodayFilterActive ? Color.white.opacity(0.2) : Color.clear)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isTodayFilterActive ? Color.blue : Color.white, lineWidth: 1)
                    )
            }
            .padding(.trailing, 10)  // Align the button to the right
        }
        .padding(.horizontal, 10)
    }

    private func colorSelectionView() -> some View {
        HStack(spacing: 15) {  // Spacing between circles
            noColorButton()  // No color button with 'x'
            colorButton("Blue", color: Color.blue)
            colorButton("Green", color: Color.green)
            colorButton("Red", color: Color.red)
            colorButton("Yellow", color: Color.yellow)
            colorButton("Purple", color: Color.purple)
        }
        .padding(.leading, 10)  // Left align the circles
        .padding(.vertical, 10)  // Add vertical padding to match spacing
    }

    private func noColorButton() -> some View {
        Button(action: {
            selectedColorCategory = nil // Show all tasks
            refreshTasks(true) // Refresh tasks to apply the filter
        }) {
            Circle()
                .stroke(Color.gray, lineWidth: 2)  // Outline for 'No Color' button
                .frame(width: 20, height: 20)
                .overlay(
                    Text("x")
                        .foregroundColor(.gray)
                        .font(.system(size: 10, weight: .bold))  // 'x' in the middle
                )
        }
    }

    private func colorButton(_ category: String, color: Color) -> some View {
        Button(action: {
            selectedColorCategory = category // Filter tasks by selected category
            refreshTasks(true) // Refresh tasks to apply the filter
        }) {
            Circle()
                .fill(color)
                .frame(width: 20, height: 20)  // Make the circles smaller
                .overlay(
                    Circle().stroke(Color.white, lineWidth: selectedColorCategory == category ? 2 : 0)
                )
        }
    }

    private var filteredReminders: [ProfessionObjective] {
        var filtered = reminders

        // Category filter
        if let selectedColorCategory = selectedColorCategory {
            filtered = filtered.filter { $0.category == selectedColorCategory }
        }

        // Today filter
        if isTodayFilterActive {
            let today = Calendar.current.startOfDay(for: Date())
            filtered = filtered.filter {
                guard let reminderTime = $0.time else { return false }
                return Calendar.current.isDate(reminderTime, inSameDayAs: today)
            }
        }

        return filtered
    }

    private var addReminderPrompt: some View {
        HStack {
            Spacer()
            Text("Tap to add a new reminder")
                .font(.subheadline)
                .foregroundColor(Color(red: 88/255, green: 88/255, blue: 88/255))
                .onTapGesture {
                    guard let userID = Auth.auth().currentUser?.uid else {
                        print("User not authenticated")
                        return
                    }
                    
                    let newReminder = ProfessionObjective(title: "", description: "", userID: userID)
                    ProfessionModel.addReminder(reminder: newReminder)
                    
                    viewModel.fetchProfessionObjectives {
                        self.reminders = viewModel.professionReminders
                    }
                }
            Spacer()
        }
        .padding()
        .background(Color(red: 15/255, green: 15/255, blue: 15/255))
        .cornerRadius(8)
    }

    private var remindersList: some View {
        ForEach(filteredReminders, id: \.id) { reminder in
            if let reminderId = reminder.id {
                SwipeableReminderRow(isEditReminderClosed: $isEditReminderClosed, reminder: reminder, onDelete: {
                    deleteReminder(reminder)
                })
                .padding(.vertical, 2)
            } else {
                Text("Error: Reminder ID not found")
                    .foregroundColor(.red)
            }
        }
    }

    private func deleteReminder(_ reminder: ProfessionObjective) {
        if let reminderId = reminder.id {
            let db = Firestore.firestore()
            db.collection("profession_objectives").document(reminderId).delete { error in
                if let error = error {
                    print("Error removing document: \(error)")
                } else {
                    print("Document successfully removed!")
                    reminders.removeAll { $0.id == reminderId }
                    refreshTasks(true)
                }
            }
        }
    }
}


struct SwipeableReminderRow: View {
    @Binding var isEditReminderClosed: Bool
    var reminder: ProfessionObjective
    var onDelete: () -> Void
    
    @State private var offset: CGFloat = 0
    @State private var isSwiped = false
    
    var body: some View {
        ZStack(alignment: .trailing) {
            HStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        onDelete()
                    }
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.white)
                        .padding()
                }
                .background(Color.red)
                .cornerRadius(8)
                .frame(width: 60)
            }
            .background(Color.red)
            .cornerRadius(8)
            
            ReminderRow(
                reminder: .constant(reminder),
                reminderId: reminder.id ?? "",
                showTimePickerForReminder: .constant(nil),
                isEditReminderClosed: $isEditReminderClosed, onDelete: onDelete,
                onRefresh: {}
            )
            .background(Color.black)
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if gesture.translation.width < 0 {
                            offset = gesture.translation.width
                            isSwiped = true
                        }
                    }
                    .onEnded { _ in
                        withAnimation {
                            if isSwiped && offset < -60 {
                                offset = -60
                            } else {
                                offset = 0
                                isSwiped = false
                            }
                        }
                    }
            )
        }
    }
}

/*
struct ObjectivesView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectivesView(isEditReminderClosed: false)
            .environmentObject(ObjectivesViewModel())
    }
}
*/
