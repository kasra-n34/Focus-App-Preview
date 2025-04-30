//
//  JournalListView.swift
//  Focus
//
//  Created by Kasra on 2024-07-17.
//
import SwiftUI

struct JournalListView: View {
    @StateObject private var viewModel = JournalViewModel()
    @State private var showingJournalEntryView = false
    @State private var editMode: EditMode = .inactive
    @State private var selectedEntry: JournalEntry?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var proceedAfterAlert = false
    @State private var alertShown = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                ZStack {
                    Capsule()
                        .fill(Color(red: 58/255, green: 58/255, blue: 58/255).opacity(0.5))
                        .frame(width: 110, height: 10)
                        .padding(.top, 8)
                    Capsule()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 100, height: 4)
                        .padding(.top, 8)
                        .presentationDetents([.fraction(0.7)])
                }

                
                ZStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(Date(), formatter: dateFormatter)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .fontWeight(.semibold)
                            .padding([.leading], 20.0)
                            .padding(.top, 30.0)

                        Text("Journal Entries")
                            .font(.largeTitle)
                            .padding(.top, 10)
                            .padding(.bottom, 20)
                            .padding(.leading, 20)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.black)

                    HStack {
                        Spacer()
                        EditButton()
                            .foregroundColor(.white)
                            .padding(.trailing, 30)
                    }
                    .padding(.bottom, 40)
                }
                .onAppear {
                    viewModel.fetchJournalEntries()
                }

                if viewModel.journalEntries.isEmpty {
                    Text("Created Journal Entries Will Appear Here")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.top, 250)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    List {
                        ForEach(viewModel.journalEntries) { entry in
                            ZStack {
                                NavigationLink(
                                    destination: JournalEntriesView(entry: entry, isPresented: $showingJournalEntryView)
                                        .environmentObject(viewModel)
                                ) {
                                    EmptyView()
                                }
                                .opacity(0) // This hides the default chevron

                                journalEntryRow(entry: entry)
                            }
                            .listRowBackground(Color.black) // Ensures the background color matches the overall view
                            .listRowInsets(EdgeInsets()) // Removes default padding to extend to the edges
                        }
                        .onDelete(perform: deleteJournalEntries)
                    }
                    .listStyle(PlainListStyle())
                    .onAppear {
                        viewModel.fetchJournalEntries()
                    }
                    .background(Color.black)
                }

                Spacer()
            }
            .background(Color.black)
            .environment(\.editMode, $editMode)
            .overlay(
                addButtonOverlay
            )
        }
        .background(Color.black)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Warning"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    proceedAfterAlert = true
                    alertShown = true
                    showingJournalEntryView = true
                }
            )
        }
        .onChange(of: showingJournalEntryView) { newValue in
            if !newValue {
                viewModel.fetchJournalEntries()
            }
        }
    }

    private func deleteJournalEntries(at offsets: IndexSet) {
        offsets.forEach { index in
            let entry = viewModel.journalEntries[index]
            viewModel.deleteJournalEntry(entry)
        }
        viewModel.journalEntries.remove(atOffsets: offsets)
    }

    private var addButtonOverlay: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    if alertShown {
                        selectedEntry = nil
                        showingJournalEntryView = true
                    } else {
                        viewModel.checkJournalingObjectiveExists { exists in
                            if exists {
                                selectedEntry = nil
                                showingJournalEntryView = true
                            } else {
                                alertMessage = "Journals won't be tracked. Add 'Track Journaling' in Objectives to track journaling entries."
                                showAlert = true
                            }
                        }
                    }
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
                    .padding(.trailing, 20)
                    .padding(.bottom, 15)

                }
                .sheet(isPresented: $showingJournalEntryView) {
                    NavigationView {
                        VStack {
                            // Add a handle at the top
                            ZStack {
                                Capsule()
                                    .fill(Color(red: 58/255, green: 58/255, blue: 58/255).opacity(0.5))
                                    .frame(width: 110, height: 10)
                                    .padding(.top, 8)
                                Capsule()
                                    .fill(Color.gray.opacity(0.5))
                                    .frame(width: 100, height: 4)
                                    .padding(.top, 8)
                                    .presentationDetents([.fraction(0.7)])
                            }
                            // The actual modal content
                            JournalEntriesView(entry: selectedEntry, isPresented: $showingJournalEntryView)
                                .environmentObject(viewModel)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .background(Color.black.edgesIgnoringSafeArea(.all))
                    }
                }
            }
        }
    }

    private func journalEntryRow(entry: JournalEntry) -> some View {
        Button(action: {
            selectedEntry = entry
            showingJournalEntryView = true
        }) {
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(entry.title)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.bottom,1)
                        Text(entry.date, style: .date)
                            .font(.system(size: 13, weight: .medium, design: .monospaced)) // Monospaced for numbers
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                Divider()
                    .background(Color.white)
                    .padding(.horizontal) // Ensures divider spans the screen width
            }
            .background(Color.black)
        }
        .buttonStyle(PlainButtonStyle()) // Ensures no button styling is applied
    }

    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter
    }
}

struct JournalListView_Previews: PreviewProvider {
    static var previews: some View {
        JournalListView()
    }
}
