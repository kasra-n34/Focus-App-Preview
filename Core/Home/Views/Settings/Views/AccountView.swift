import SwiftUI
import UIKit
import CropViewController
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct AccountView: View {
    @State private var isLoggedOut = false
    @State private var username: String = ""
    @State private var originalUsername: String = ""
    @State private var email: String = ""
    @State private var showWeeklyReport = false
    @State private var showImagePicker = false
    @State private var profileImage: UIImage?
    @State private var showImageCropper = false
    @State private var imageToCrop: UIImage?
    @State private var showSaveAlert = false
    @State private var showSaveSuccess = false
    @State private var showRemoveAlert = false
    @State private var profilePhotoURL: URL?
    @State private var showPublicProfileCard = false
    @State private var opacity: Double = 0.0 // New state property for fade-in effect
    
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        if isLoggedOut {
            LoginView()
        } else {
            NavigationStack {
                ZStack {
                    Color(red: 28/255, green: 28/255, blue: 28/255).edgesIgnoringSafeArea(.all)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Spacer()
                        headerView
                        Text("Set your account profile preferences here.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20)
                            .fixedSize(horizontal: false, vertical: true)
                        
                       
                        HStack {
                            Spacer()
                            profileImageView
                            Spacer()
                        }
                        if profileImage != nil {
                            HStack {
                                Spacer()
                                removePhotoButton
                                Spacer()
                            }
                        }
                        
                        userInfoFields
                        if username != originalUsername {
                            saveChangesButton
                        }
                        Spacer()
                        Spacer()
                        //viewPublicProfileCardButton
                        //weeklyReportButton
                        logOutButton
                        Spacer()
                    }
                    .padding()
                    .navigationBarTitle("", displayMode: .inline)
                    .opacity(opacity) // Apply opacity modifier
                }
                .onChange(of: imageToCrop) { _ in
                    showImageCropper = imageToCrop != nil
                }
                .onChange(of: profileImage) { _ in
                    if let newImage = profileImage {
                        Task {
                            await updateProfilePhoto(image: newImage)
                        }
                    }
                }
                .onAppear {
                    withAnimation(.easeIn(duration: 0.6)) { // Apply fade-in animation
                        opacity = 1.0
                    }
                    Task {
                        await fetchUserData()
                    }
                }
            }
        }
    }
    
    
    var headerView: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .foregroundColor(.blue)
                .font(.title)
            
            Text("Account")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .padding(.top, 30)
        .padding(.leading, 20)
    }
    
    var profileImageView: some View {
        Button(action: {
            showImagePicker.toggle()
        }) {
            ZStack {
                if let image = profileImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 145, height: 145)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                } else {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 145, height: 145)
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140, height: 140)
                        .foregroundColor(.black)
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .offset(x: 35, y: 35)
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: $imageToCrop)
        }
        .sheet(isPresented: $showImageCropper) {
            ImageCropper(image: $imageToCrop, croppedImage: $profileImage, isPresented: $showImageCropper)
        }
    }
    
    var removePhotoButton: some View {
        Button(action: {
            Task {
                await removeProfilePhoto()
            }
        }) {
            Text("Remove Photo")
                .foregroundColor(.red)
                .font(.footnote)
        }
        .alert(isPresented: $showRemoveAlert) {
            Alert(
                title: Text(showSaveSuccess ? "Success" : "Error"),
                message: Text(showSaveSuccess ? "Profile photo removed successfully" : "Failed to remove profile photo"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    var userInfoFields: some View {
        VStack(alignment: .leading, spacing: 15) {
            TextField("Username", text: $username)
                .padding()
                .background(Color(red: 18/255, green: 18/255, blue: 18/255))
                .cornerRadius(10)
                .foregroundColor(.white)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                .onChange(of: username) { newValue in
                    if newValue.count > viewModel.fullnameCharacterLimit {
                        username = String(newValue.prefix(viewModel.fullnameCharacterLimit))
                    }
                }
                .onSubmit {
                    Task {
                        await saveUsername()
                    }
                }
                
            TextField("Email", text: $email)
                .padding()
                .background(Color(red: 18/255, green: 18/255, blue: 18/255))
                .foregroundColor(.gray)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                .disabled(true) // Disables editing of the email field
        }
        .padding(.horizontal)
    }

    var saveChangesButton: some View {
        HStack(spacing: 10) {
            Button(action: {
                Task {
                    await saveUsername()
                }
            }) {
                Text("Save Changes")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: 160)
                    .background(Color(red: 18/255, green: 88/255, blue: 18/255))
                    .cornerRadius(10)
            }
            .alert(isPresented: $showSaveAlert) {
                if showSaveSuccess {
                    return Alert(title: Text("Success"), message: Text("Username updated successfully"), dismissButton: .default(Text("OK")))
                } else {
                    return Alert(title: Text("Error"), message: Text("Failed to update username"), dismissButton: .default(Text("OK")))
                }
            }
            
            Button(action: {
                username = originalUsername
            }) {
                Text("Cancel Changes")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: 160)
                    .background(Color(red: 88/255, green: 18/255, blue: 18/255))
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal)
    }

/*
    var viewPublicProfileCardButton: some View {
        Button(action: {
            showPublicProfileCard.toggle()
        }) {
            Text("View Public Profile Card")
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(red: 18/255, green: 18/255, blue: 18/255))
                .cornerRadius(10)
        }
        .padding(.horizontal)
        .sheet(isPresented: $showPublicProfileCard) {
            PublicProfileCardView() // Placeholder for the view you want to show
        }
    }
*/
 
    var weeklyReportButton: some View {
        Button(action: {
            //showWeeklyReport.toggle()
        }) {
            Text("View Weekly Report")
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.black)
                .cornerRadius(10)
        }
        .padding(.horizontal)
        .sheet(isPresented: $showWeeklyReport) {
            WeeklyReportView()
        }
    }
    
    var logOutButton: some View {
        Button("Log Out") {
            Task {
                do {
                    try await viewModel.signOut { success in
                        if success {
                            isLoggedOut = true
                            print("Logged Out Successfully")
                        }
                    }
                } catch {
                    print("Failed to log out: \(error)")
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(red: 88/255, green: 18/255, blue: 18/255))
        .foregroundColor(.white)
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    func fetchUserData() async {
        await getUsername { name in
            username = name
            originalUsername = name // Store the original username
        }
        await getEmail { userEmail in
            email = userEmail
        }
        fetchProfilePhotoURL()
    }

    func saveUsername() async {
        guard username.count <= viewModel.fullnameCharacterLimit else {
            showSaveAlert = true
            showSaveSuccess = false
            return
        }
        updateUsername(newUsername: username) { success in
            showSaveSuccess = success
            showSaveAlert = true
            if success {
                originalUsername = username // Update the original username after successful save
            }
        }
    }

    func updateProfilePhoto(image: UIImage) async {
        uploadProfilePhoto(image: image) { url in
            if let url = url {
                print("Profile photo URL: \(url.absoluteString)")
                saveProfilePhotoURL(url: url)
                profilePhotoURL = url // Save the URL to the state variable
            } else {
                print("Failed to upload profile photo")
            }
        }
    }
    
    func removeProfilePhoto() async {
        deleteProfilePhoto { success in
            showSaveSuccess = success
            showRemoveAlert = true
            if success {
                profileImage = nil // Remove the profile image from the state
            }
        }
    }

    func fetchProfilePhotoURL() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let docRef = Firestore.firestore().collection("users").document(uid)
        docRef.getDocument { document, error in
            if let document = document, document.exists {
                if let data = document.data(), let photoURLString = data["profilePhotoURL"] as? String, let photoURL = URL(string: photoURLString) {
                    profilePhotoURL = photoURL
                    fetchProfilePhoto(from: photoURL)
                }
            } else {
                print("Document does not exist or error fetching document: \(String(describing: error))")
            }
        }
    }

    func fetchProfilePhoto(from url: URL) {
        let storageRef = Storage.storage().reference(forURL: url.absoluteString)
        storageRef.getData(maxSize: Int64(5 * 1024 * 1024)) { data, error in // Increased the max size to 5MB
            if let error = error {
                print("Error fetching profile photo: \(error.localizedDescription)")
            } else if let data = data, let image = UIImage(data: data) {
                profileImage = image
            }
        }
    }
}



struct WeeklyReportView: View {
    var body: some View {
        Text("Weekly Report")
            .font(.largeTitle)
            .foregroundColor(.white)
            .padding()
            .background(Color(red: 18/255, green: 18/255, blue: 18/255))
            .cornerRadius(10)
            .shadow(radius: 5)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true)
        }
    }
}

struct PublicProfileCardView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var profilePhotoURL: URL?
    @State private var focusRating: Int = 0
    @State private var physicalityRating: Int = 0
    @State private var mindfulnessRating: Int = 0
    @State private var professionRating: Int = 0

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.black]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        if let url = profilePhotoURL {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                    .shadow(radius: 5)
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 80, height: 80)
                            }
                        } else {
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 200, height: 200)
                                .overlay(Image(systemName: "person.fill").foregroundColor(.white))
                        }
                        
                        Text(username)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top)
                    }
                    
                    Spacer()
                    
                    VStack {
                        ZStack {
                            FocusRing(progress: .constant(Double(Float(focusRating)) / 100),
                                      color1: Color.gray, color2: Color.white)
                            .frame(width: 100, height: 100)
                            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                            
                            Text("\(focusRating)")
                                .font(.system(size: 25, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.white, Color.gray]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                    }
                    .padding(.trailing, 20)
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)
                
                Divider()
                    .background(Color.gray)
                    .padding(.horizontal, 20)
                
                HStack {
                    Text("User Stats")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.gray, Color.white]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 5)
                
                HStack(spacing: 25) {
                    MiniPillarCard(
                        title: "Physicality",
                        rating: physicalityRating,
                        color: .red,
                        icon: "figure.walk.circle.fill"
                    )
                    MiniPillarCard(
                        title: "Mindfulness",
                        rating: mindfulnessRating,
                        color: .green,
                        icon: "brain.head.profile.fill"
                    )
                    MiniPillarCard(
                        title: "Produvtivity",
                        rating: professionRating,
                        color: .blue,
                        icon: "briefcase.circle.fill"
                    )
                }
                .padding(.horizontal, 10)
                
                Spacer()
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Done")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 18/255, green: 18/255, blue: 18/255))
                        .cornerRadius(10)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            Task {
                await fetchUserData()
            }
        }
    }
    
    func fetchUserData() async {
        guard let currentUser = viewModel.currentUser else { return }
        
        username = currentUser.fullname
        email = currentUser.email
        profilePhotoURL = URL(string: currentUser.profilePhotoURL)
        focusRating = Int(currentUser.focusRating)
        physicalityRating = Int(currentUser.physicalityRating)
        mindfulnessRating = Int(currentUser.mindfulnessRating)
        professionRating = Int(currentUser.professionRating)
    }
}


struct MiniPillarCard: View {
    var title: String
    var rating: Int
    var color: Color
    var icon: String

    var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .cornerRadius(15)
                .frame(width: 100, height: 120)
                .shadow(color: color.opacity(0.4), radius: 8, x: 0, y: 4)

            VStack(alignment: .center, spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)

                Text(title)
                    .font(.caption)
                    .foregroundColor(.white)

                // Gradient applied to rating text
                Text("\(rating)")
                    .font(.headline)
                    .bold()
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [color, Color.white]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .padding(10)
        }
    }
}


struct ImageCropper: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var croppedImage: UIImage?
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> CropViewController {
        let cropViewController = CropViewController(image: image!)
        cropViewController.delegate = context.coordinator
        cropViewController.aspectRatioPreset = .presetSquare
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.resetAspectRatioEnabled = false
        cropViewController.cropView.cropBoxResizeEnabled = true
        return cropViewController
    }

    func updateUIViewController(_ uiViewController: CropViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, CropViewControllerDelegate {
        let parent: ImageCropper

        init(_ parent: ImageCropper) {
            self.parent = parent
        }

        func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
            parent.croppedImage = image.circularMasked
            parent.isPresented = false
        }

        func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
            parent.isPresented = false
        }
    }
}

extension UIImage {
    var circularMasked: UIImage? {
        let square = CGSize(width: min(size.width, size.height), height: min(size.width, size.height))
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: square))
        imageView.contentMode = .scaleAspectFill
        imageView.image = self
        imageView.layer.cornerRadius = square.width / 2
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
            .environmentObject(AuthViewModel()) // Provide the environment object here
    }
}

