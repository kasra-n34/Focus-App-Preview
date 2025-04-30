import SwiftUI

struct SignUpView: View {
    
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var confirmPassword = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                VStack(spacing: 10) {
                    // Welcome Message
                    Text("Register Your Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    Text("Please fill in the details to sign up")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
                Spacer()
                
                // Form Fields
                VStack(spacing: 24) {
                    InputView(text: $email, title: "Email Address", placeholder: "johndoe@example.com", iconName: "envelope")
                        .autocapitalization(.none)
                    
                    InputView(text: $name, title: "Full Name", placeholder: "John Doe", iconName: "person")
                    
                    InputView(text: $password, title: "Password", placeholder: "Enter your password", isSecureField: true, iconName: "lock")
                    
                    ZStack(alignment: .trailing) {
                        InputView(text: $confirmPassword, title: "Confirm Password", placeholder: "Re-enter your password", isSecureField: true, iconName: "lock")
                        
                        if !password.isEmpty && !confirmPassword.isEmpty {
                            if confirmPassword == password {
                                Image(systemName: "checkmark.circle.fill")
                                    .imageScale(.large)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(.systemGreen))
                                    .padding(.trailing)
                            } else {
                                Image(systemName: "xmark.circle.fill")
                                    .imageScale(.large)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(.systemRed))
                                    .padding(.trailing)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Sign Up button
                Button {
                    Task {
                        do {
                            try await viewModel.makeUser(withEmail: email, password: password, name: name)
                            alertMessage = "Verification email sent. Please check your inbox."
                            showAlert = true
                        } catch {
                            if let errorMessage = viewModel.errorMessage {
                                alertMessage = errorMessage
                                showAlert = true
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text("Sign Up")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                }
                .background(Color(red: 18/255, green: 18/255, blue: 18/255))
                .cornerRadius(10)
                .padding(.vertical, 24)
                .disabled(!isValidForm)
                .opacity(isValidForm ? 1.0 : 0.5)
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: alertMessage == "Verification email sent. Please check your inbox." ? Text("Notice") : Text("Error"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK")) {
                            showAlert = false
                        }
                    )
                }
                
                // Sign In button
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 6) {
                        Text("Already have an account?")
                        Text("Sign in")
                            .fontWeight(.bold)
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                }
                
                Spacer()
            }
        }
    }
}

extension SignUpView: AuthenticationFormProtocol {
    var isValidForm: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
        && confirmPassword == password
        && !name.isEmpty
    }
}

#Preview {
    SignUpView()
        .environmentObject(AuthViewModel())
}
