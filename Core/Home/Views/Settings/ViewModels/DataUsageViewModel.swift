import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

func allowMyFitnessPalData(toggle: Bool) {
    guard let uid = Auth.auth().currentUser?.uid else {
        print("User not logged in")
        return
    }

    let db = Firestore.firestore()
    db.collection("users").document(uid).setData([ "MyFitnessPal": toggle ], merge: true) { error in
        if let error = error {
            print("Error updating document: \(error)")
        } else {
            print("Document successfully updated")
        }
    }
}

func loadMyFitnessPalSetting(completion: @escaping (Bool) -> Void) {
    guard let uid = Auth.auth().currentUser?.uid else {
        print("User not logged in")
        completion(false)
        return
    }
    
    let db = Firestore.firestore()
    let userDocRef = db.collection("users").document(uid)
    
    userDocRef.getDocument { document, error in
        if let document = document, document.exists {
            let data = document.data()
            let myFitnessPalData = data?["MyFitnessPal"] as? Bool ?? false
            completion(myFitnessPalData)
        } else {
            print("Document does not exist")
            completion(false)
        }
    }
}
