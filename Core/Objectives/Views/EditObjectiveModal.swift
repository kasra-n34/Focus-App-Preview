import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine


struct EditObjectiveModal: View {
    @Binding var task: CustomTask
    let categoryGradient: LinearGradient
    let collection: String
    let deleteAction: () -> Void
    @Environment(\.presentationMode) var presentationMode

    @State private var progress: Int
    @State private var showNotificationSettings: Bool = false
    @State private var notifications: [NotificationModel] = []
    @State private var isEditingProgress: Bool = false
    @State private var progressInput: String = ""
    @State private var isAutoTrackEnabled: Bool = false
    @State private var isInitialized = false  // Guard flag for initialization
    
    @FocusState private var isProgressFieldFocused: Bool // Focus state for TextField
    
    @ObservedObject var viewModel = ObjectivesViewModel()

    init(task: Binding<CustomTask>, categoryGradient: LinearGradient, collection: String, deleteAction: @escaping () -> Void) {
        self._task = task
        self.categoryGradient = categoryGradient
        self._progress = State(initialValue: task.wrappedValue.progress)
        self.collection = collection
        self.deleteAction = deleteAction

        if let taskNotifications = task.wrappedValue.notifications {
            self._notifications = State(initialValue: taskNotifications)
        }
        
        self._isAutoTrackEnabled = State(initialValue: task.wrappedValue.isAutoTrackEnabled)
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    // Handle at the very top
                    ZStack {
                        Capsule()
                            .fill(Color(red: 58/255, green: 58/255, blue: 58/255).opacity(0.5))
                            .frame(width: 110, height: 10)
                        Capsule()
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 100, height: 4)
                    }
                    
                    Spacer()
                

                    Text("Edit Objective")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top)

                    Text("\(task.title) (\(task.frequency ?? "Unknown"))")
                        .foregroundColor(.white)
                        .padding()
                        .padding(.horizontal)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(8)
                        .padding(.bottom)
                        .onChange(of: task.title) { newValue in
                            if isInitialized && task.title != newValue {
                                viewModel.updateTask(task: task, collection: collection)
                            }
                        }

                    CustomProgressBar(progress: Float(progress) / Float(task.goal), gradient: categoryGradient)
                        .scaleEffect(x: 1, y: 3, anchor: .center)
                        .padding(.horizontal)
                        .shadow(color: Color.white.opacity(0.8), radius: 5, x: 0, y: 0)
                        .animation(.easeInOut(duration: 0.3), value: progress)

                    HStack {
                        Button(action: {
                            if progress > 0 {
                                let amount = -1
                                progress += amount
                                updateTaskProgress(by: amount)
                            }
                        }) {
                            Image(systemName: "minus.circle")
                                .foregroundColor(isAutoTrackEnabled ? .gray : .white)
                                .font(.largeTitle)
                        }
                        .padding()
                        .disabled(isAutoTrackEnabled)

                        if isEditingProgress {
                            TextField("\(progress)", text: $progressInput, onCommit: {
                                if let newProgress = Int(progressInput), newProgress >= 0, newProgress <= task.goal {
                                    let amount = newProgress - progress
                                    progress = newProgress
                                    updateTaskProgress(by: amount)
                                }
                                isEditingProgress = false
                            })
                            .keyboardType(.numberPad)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(8)
                            .frame(width: 80, height: 40)
                            .onAppear {
                                progressInput = "\(progress)"
                                isProgressFieldFocused = true  // Automatically focus the TextField
                            }
                            .focused($isProgressFieldFocused)  // Track the focus state
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    Button("Done") {
                                        if let newProgress = Int(progressInput), newProgress >= 0, newProgress <= task.goal {
                                            let amount = newProgress - progress
                                            progress = newProgress
                                            updateTaskProgress(by: amount)
                                        }
                                        isEditingProgress = false
                                        isProgressFieldFocused = false  // Dismiss the keyboard
                                    }
                                }
                            }
                            .disabled(isAutoTrackEnabled)
                        } else {
                            Text(isAutoTrackEnabled ? "Auto" : "\(progress) / \(task.goal)")
                                .foregroundColor(isAutoTrackEnabled ? .gray : .white)
                                .font(.system(size: 19, weight: .semibold, design: .monospaced))
                                .onTapGesture {
                                    if !isAutoTrackEnabled {
                                        isEditingProgress = true
                                        isProgressFieldFocused = true  // Ensure the field gains focus
                                    }
                                }
                        }

                        Button(action: {
                            if progress < task.goal {
                                let amount = 1
                                progress += amount
                                updateTaskProgress(by: amount)
                            }
                        }) {
                            Image(systemName: "plus.circle")
                                .foregroundColor(isAutoTrackEnabled ? .gray : .white)
                                .font(.largeTitle)
                        }
                        .padding()
                        .disabled(isAutoTrackEnabled)
                    }
                    
                    NavigationLink(destination: NotificationSettingsView(notifications: $notifications, currentCategory: task.category, onSetNotifications: { updatedNotifications in
                        notifications = updatedNotifications
                        task.notifications = updatedNotifications
                        viewModel.updateTask(task: task, collection: collection)
                    })) {
                        Text("Edit Notifications")
                            .foregroundColor(.white)
                            .padding()
                            .frame(minWidth: 320)
                            .background(Color(red: 18/255, green: 18/255, blue: 18/255))
                            .cornerRadius(10)
                    }
                    .padding(.top)

                    Button(action: {
                        viewModel.deleteTaskFromFirestore(task: task, collection: collection)
                        deleteAction()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Delete Task")
                            .foregroundColor(.white)
                            .padding()
                            .frame(minWidth: 320)
                            .background(Color(red: 88/255, green: 18/255, blue: 18/255))
                            .cornerRadius(8)
                    }
                    .padding(.bottom, 10)
                    
                    Spacer()
                }
                .padding()
                .background(Color.black)
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding(.horizontal)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if (!isInitialized) {
                self.progress = task.progress
                self.notifications = task.notifications ?? []
                self.isAutoTrackEnabled = task.isAutoTrackEnabled
                isInitialized = true

                if (task.id == nil) {
                    fetchTaskID()
                }
            }
        }
    }

    private func updateTaskProgress(by amount: Int) {
        task.progress += amount
        task.weeklyProgress += amount
        task.monthlyProgress += amount
        task.allTimeProgress = (task.allTimeProgress ?? 0) + amount
        viewModel.updateTask(task: task, collection: collection)
    }

    private func fetchTaskID() {
        viewModel.fetchTaskID(byTitle: task.title, inCollection: collection) { fetchedID in
            if let fetchedID = fetchedID {
                self.task.id = fetchedID
                print("Fetched Task ID: \(fetchedID)")
            } else {
                print("Task ID not found for task: \(task.title)")
            }
        }
    }
}


extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .map { $0.keyboardHeight }
        
        let willHide = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

private extension Notification {
    var keyboardHeight: CGFloat {
        (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}
