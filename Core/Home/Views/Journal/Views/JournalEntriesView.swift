import SwiftUI
import FirebaseAuth

struct JournalEntriesView: View {
    @StateObject private var viewModel = JournalViewModel()
    @Binding var isPresented: Bool
    var entry: JournalEntry?

    init(entry: JournalEntry? = nil, isPresented: Binding<Bool>) {
        self.entry = entry
        _isPresented = isPresented
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    JournalTextField(placeholder: "Enter Your Title", text: $viewModel.title)
                        .frame(height: 50)
                        .background(Color.black)
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color(red: 58/255, green: 58/255, blue: 58/255)),
                            alignment: .bottom
                        )
                        .padding(.vertical, 10)

                    Text("Entry Date: \(formattedDate(date: viewModel.date))")
                        .font(.system(size: 14, weight: .medium, design: .monospaced)) // Monospaced for numbers
                        .padding(.top, 5)
                        .padding(.bottom, 15)
                        .foregroundColor(.gray)

                    JournalTextEditor(text: $viewModel.bodyText)
                        .frame(maxHeight: 550)
                        .background(Color.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color(red: 58/255, green: 58/255, blue: 58/255), lineWidth: 1)
                        )
                        .padding(.vertical, 10)

                    Spacer()

                    Button(action: {
                        if let entry = entry {
                            viewModel.updateJournalEntry(JournalEntry(id: entry.id, title: viewModel.title, bodyText: viewModel.bodyText, date: viewModel.date)) { success in
                                if success {
                                    isPresented = false
                                } else {
                                    print("Failed to update journal entry")
                                }
                            }
                        } else {
                            viewModel.saveJournalEntry { success in
                                if success {
                                    isPresented = false
                                } else {
                                    print("Failed to save journal entry")
                                }
                            }
                        }
                    }) {
                        Text("Save")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(viewModel.title.isEmpty || viewModel.bodyText.isEmpty ? Color(red: 68/255, green: 18/255, blue: 18/255) : Color(red: 18/255, green: 18/255, blue: 18/255))
                            .cornerRadius(10)
                    }
                    .disabled(viewModel.title.isEmpty || viewModel.bodyText.isEmpty)
                    .padding(.vertical, 10)
                }
                .padding(.horizontal, 20)
                .onAppear {
                    if let entry = entry {
                        viewModel.title = entry.title
                        viewModel.bodyText = entry.bodyText
                        viewModel.date = entry.date
                    } else {
                        viewModel.date = Date()
                    }

                    if let userID = Auth.auth().currentUser?.uid {
                        print("Current user ID: \(userID)")
                    } else {
                        print("No user is currently signed in.")
                    }
                }
            }
        }
    }

    func formattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}



