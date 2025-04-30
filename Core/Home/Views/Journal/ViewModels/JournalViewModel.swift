import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

struct JournalEntry: Identifiable {
    var id: String
    var title: String
    var bodyText: String
    var date: Date
}

class JournalViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var bodyText: String = ""
    @Published var date: Date = Date()
    @Published var journalEntries: [JournalEntry] = []

    private let db = Firestore.firestore()

    func saveJournalEntry(completion: @escaping (Bool) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: No user is currently signed in.")
            completion(false)
            return
        }

        let journalEntry = [
            "title": title,
            "bodyText": bodyText,
            "date": Timestamp(date: date)
        ] as [String : Any]

        print("Attempting to save journal entry for user ID: \(userID)")
        
        db.collection("journal_entries").document(userID).collection("entries").addDocument(data: journalEntry) { [weak self] error in
            if let error = error {
                print("Error saving journal entry: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Journal entry successfully saved!")
                self?.incrementJournalingObjective(for: userID) { success in
                    if success {
                        self?.fetchJournalEntries()
                    }
                    completion(success)
                }
            }
        }
    }

    func updateJournalEntry(_ entry: JournalEntry, completion: @escaping (Bool) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: No user is currently signed in.")
            completion(false)
            return
        }

        let updatedEntry = [
            "title": entry.title,
            "bodyText": entry.bodyText,
            "date": Timestamp(date: entry.date)
        ] as [String : Any]

        db.collection("journal_entries").document(userID).collection("entries").document(entry.id).setData(updatedEntry) { error in
            if let error = error {
                print("Error updating journal entry: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Journal entry successfully updated!")
                self.fetchJournalEntries()
                completion(true)
            }
        }
    }

    func fetchJournalEntries() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: No user is currently signed in.")
            return
        }

        db.collection("journal_entries").document(userID).collection("entries").order(by: "date", descending: true).getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching journal entries: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }

            self?.journalEntries = documents.map { doc -> JournalEntry in
                let data = doc.data()
                let id = doc.documentID
                let title = data["title"] as? String ?? ""
                let bodyText = data["bodyText"] as? String ?? ""
                let date = (data["date"] as? Timestamp)?.dateValue() ?? Date()
                return JournalEntry(id: id, title: title, bodyText: bodyText, date: date)
            }
        }
    }

    func deleteJournalEntry(_ entry: JournalEntry) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: No user is currently signed in.")
            return
        }

        db.collection("journal_entries").document(userID).collection("entries").document(entry.id).delete { [weak self] error in
            if let error = error {
                print("Error deleting journal entry: \(error.localizedDescription)")
            } else {
                print("Journal entry successfully deleted!")
                self?.fetchJournalEntries()
            }
        }
    }
    
    func checkJournalingObjectiveExists(completion: @escaping (Bool) -> Void) {
            guard let userID = Auth.auth().currentUser?.uid else {
                print("Error: No user is currently signed in.")
                completion(false)
                return
            }

            let objectivesRef = db.collection("mindfulness_objectives")
                .whereField("userID", isEqualTo: userID)
                .whereField("title", isEqualTo: "Track Journaling")

            objectivesRef.getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error checking journaling objective: \(error.localizedDescription)")
                    completion(false)
                    return
                }

                guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                    print("No journaling objective found for user")
                    completion(false)
                    return
                }

                print("Journaling objective exists")
                completion(true)
            }
        }

    private func incrementJournalingObjective(for userID: String, completion: @escaping (Bool) -> Void) {
        let objectivesRef = db.collection("mindfulness_objectives").whereField("userID", isEqualTo: userID).whereField("title", isEqualTo: "Track Journaling")

        objectivesRef.getDocuments { querySnapshot, error in
            if let error = error {
                print("Error fetching journaling objective: \(error.localizedDescription)")
                completion(false)
                return
            }

            guard let document = querySnapshot?.documents.first else {
                print("No journaling objective found for user")
                completion(true)
                return
            }

            let documentRef = document.reference
            documentRef.updateData(["progress": FieldValue.increment(Int64(1))]) { error in
                if let error = error {
                    print("Error updating journaling objective: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Journaling objective successfully incremented")
                    completion(true)
                }
            }
        }
    }
}
