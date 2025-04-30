import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices

struct LoginView: View {
    
    // State variables for form fields
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert: Bool = false
    @State private var showVerificationAlert: Bool = false
    @State private var alertMessage: String = ""
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack {
                    VStack(spacing: 25) {
                        // App Logo or Welcome Icon
                        Image("icon")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.white)
                            .padding(.top, 50)
                        
                        // Welcome Message
                        VStack (spacing: 10) {
                            Text("Welcome to Focus")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Please sign in to continue")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.bottom, 25)
                    .padding(.horizontal)
                    
                    // Form Fields
                    VStack(spacing: 24) {
                        InputView(text: $email, title: "Email Address", placeholder: "johndoe@example.com", iconName: "envelope")
                            .autocapitalization(.none)
                        InputView(text: $password, title: "Password", placeholder: "Enter your password", isSecureField: true, iconName: "lock")
                    }
                    .padding(.horizontal)
                    
                    // Log in button
                    Button {
                        Task {
                            do {
                                try await viewModel.signIn(withEmail: email, password: password)
                                if !viewModel.isEmailVerified {
                                    try await viewModel.userSession?.sendEmailVerification()
                                    alertMessage = "Your email is not verified. A new verification email has been sent to your inbox. Please check your email and verify your account."
                                    showAlert = true
                                }
                            } catch {
                                if let errorMessage = viewModel.errorMessage {
                                    alertMessage = errorMessage
                                    showAlert = true
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text("Sign In")
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
                            title: Text("Error"),
                            message: Text(alertMessage),
                            dismissButton: .default(Text("OK")) {
                                showAlert = false
                            }
                        )
                    }
                    
                    HStack {
                        VStack {
                            Divider()
                                .overlay(Color(.white))
                        }
                        Text("or")
                            .foregroundColor(.white)
                        VStack {
                            Divider()
                                .overlay(Color(.white))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, -15)
                    
                    HStack(spacing: 10) {
                        Button {
                            // Handle Google sign-in action
                            Task {
                                let success = await viewModel.signInWithGoogle()
                                if !success {
                                    if let errorMessage = viewModel.errorMessage {
                                        alertMessage = errorMessage
                                    } else {
                                        alertMessage = "Failed to sign in with Google."
                                    }
                                    showAlert = true
                                }
                            }
                        } label: {
                            HStack() {
                            
                                Image("google-logo")
                                    .resizable()
                                    .frame(width: 12, height: 12)
                                    
                              
                                Text("Google Sign In")
                                    .foregroundColor(.white)
                                    .font(.body)
                                    .lineLimit(1)
                                
                              
                          
                                
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 25/255, green: 25/255, blue: 25/255))
                            .cornerRadius(8)
                        }
                        
                        SignInWithAppleButton(
                            onRequest: { request in
                                request.requestedScopes = [.fullName, .email]
                            },
                            onCompletion: { result in
                                switch result {
                                case .success(let authorization):
                                    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                                        Task {
                                            await viewModel.handleAppleSignIn(credential: appleIDCredential)
                                        }
                                    }
                                case .failure(let error):
                                    alertMessage = "Apple Sign-In failed: \(error.localizedDescription)"
                                    showAlert = true
                                }
                            }
                        )
                        .signInWithAppleButtonStyle(.white)
                        .frame(height: 48)
                        .cornerRadius(8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.bottom)
                    
                    // Link to signup view
                    NavigationLink {
                        SignUpView()
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        HStack(spacing: 6) {
                            Text("Don't have an account?")
                            Text("Sign up")
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
}

extension LoginView: AuthenticationFormProtocol {
    var isValidForm: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
