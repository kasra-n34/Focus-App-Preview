//
//  AccountViewModel.swift
//  Focus
//
//  Created by Kasra on 2024-07-15.
//

import Foundation
import Firebase
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

let db = Firestore.firestore()

func getUsername(completion: @escaping (String) -> Void) async {
    // Ensure there is a current user
    guard let uid = Auth.auth().currentUser?.uid else {
        print("User not logged in")
        completion("User not logged in")
        return
    }
    
    // Create a dynamic reference to the user's document using the user ID
    let docRef = Firestore.firestore().collection("users").document(uid)
    
    do {
        let document = try await docRef.getDocument()
        if document.exists {
            if let data = document.data(), let name = data["fullname"] as? String {
                completion(name)
            } else {
                print("Username field does not exist")
                completion("No username")
            }
        } else {
            print("Document does not exist")
            completion("No document")
        }
    } catch {
        print("Error getting document: \(error)")
        completion("Error")
    }
}

func updateUsername(newUsername: String, completion: @escaping (Bool) -> Void) {
    guard let uid = Auth.auth().currentUser?.uid else {
        print("User not logged in")
        completion(false)
        return
    }
    
    let docRef = db.collection("users").document(uid)
    
    docRef.updateData(["fullname": newUsername]) { error in
        if let error = error {
            print("Error updating username: \(error.localizedDescription)")
            completion(false)
        } else {
            print("Username updated successfully")
            completion(true)
        }
    }
}


// Function to upload profile photo to Firebase Storage
func uploadProfilePhoto(image: UIImage, completion: @escaping (URL?) -> Void) {
    // Convert UIImage to JPEG data with 80% quality
    guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
    
    // Get a reference to Firebase Storage using the default Firebase App
    let storageRef = Storage.storage().reference().child("profile_photos").child("\(Auth.auth().currentUser?.uid ?? "unknown").jpg")
    
    // Upload the image data to the specified reference
    storageRef.putData(imageData, metadata: nil) { metadata, error in
        if let error = error {
            // Print error if upload fails
            print("Error uploading image: \(error.localizedDescription)")
            completion(nil)
            return
        }
        // Get the download URL of the uploaded image
        storageRef.downloadURL { url, error in
            if let error = error {
                // Print error if getting download URL fails
                print("Error getting download URL: \(error.localizedDescription)")
                completion(nil)
                return
            }
            // Pass the URL to the completion handler
            completion(url)
        }
    }
}

// Function to save profile photo URL to Firestore
func saveProfilePhotoURL(url: URL) {
    // Ensure there is a current user
    guard let uid = Auth.auth().currentUser?.uid else { return }
    
    // Get a reference to Firestore
    let db = Firestore.firestore()
    
    // Update the user's document with the profile photo URL
    db.collection("users").document(uid).updateData([
        "profilePhotoURL": url.absoluteString
    ]) { error in
        if let error = error {
            // Print error if saving URL fails
            print("Error saving profile photo URL: \(error.localizedDescription)")
        } else {
            // Print success message
            print("Profile photo URL saved successfully")
        }
    }
}

// Function to update profile photo
func updateProfilePhoto(image: UIImage) {
    // First, upload the profile photo
    uploadProfilePhoto(image: image) { url in
        if let url = url {
            // If upload is successful, save the profile photo URL
            saveProfilePhotoURL(url: url)
        } else {
            // Print failure message if upload fails
            print("Failed to upload profile photo")
        }
    }
}

func deleteProfilePhoto(completion: @escaping (Bool) -> Void) {
    guard let uid = Auth.auth().currentUser?.uid else {
        print("User not logged in")
        completion(false)
        return
    }
    
    let storageRef = Storage.storage().reference().child("profile_photos").child("\(uid).jpg")
    
    // Delete the photo from Firebase Storage
    storageRef.delete { error in
        if let error = error {
            print("Error deleting image: \(error.localizedDescription)")
            completion(false)
            return
        }
        
        // Remove the photo URL from Firestore
        let docRef = db.collection("users").document(uid)
        docRef.updateData(["profilePhotoURL": FieldValue.delete()]) { error in
            if let error = error {
                print("Error removing profile photo URL: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Profile photo URL removed successfully")
                completion(true)
            }
        }
    }
}

func deleteAccount(completion: @escaping (Bool) -> Void) {
    guard let user = Auth.auth().currentUser else {
        print("User not logged in")
        completion(false)
        return
    }
    
    let uid = user.uid
    
    deleteProfilePhoto { success in
        if success {
            let docRef = db.collection("users").document(uid)
            docRef.delete { error in
                if let error = error {
                    print("Error deleting user document: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                user.delete { error in
                    if let error = error {
                        print("Error deleting user account: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("User account deleted successfully")
                        completion(true)
                    }
                }
            }
        } else {
            completion(false)
        }
    }
}


func getEmail(completion: @escaping (String) -> Void) async {
    // Ensure there is a current user signed in
    guard let uid = Auth.auth().currentUser?.uid else {
        print("User not logged in")
        completion("User not logged in")
        return
    }
    
    // Create a dynamic reference to the user's document using the user ID
    let docRef = Firestore.firestore().collection("users").document(uid)
    
    do {
        let document = try await docRef.getDocument()
        if document.exists {
            if let data = document.data(), let userEmail = data["email"] as? String {
                completion(userEmail)
            } else {
                print("Email field does not exist")
                completion("No email")
            }
        } else {
            print("Document does not exist")
            completion("No document")
        }
    } catch {
        print("Error getting document: \(error)")
        completion("Error")
    }
}
