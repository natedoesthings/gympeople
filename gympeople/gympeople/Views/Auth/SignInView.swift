//
//  SignInView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/18/25.
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State var email: String = ""
    @State var password: String = ""
    @State private var isCreatingAccount: Bool = true
    @State private var validEmail: Bool = true
    @State private var errorMessage: String = ""
    
    var body: some View {
        VStack(spacing: 24) {
            // --- TOP RIGHT LOGO ---
            HStack {
                Spacer()
                Image("gympeople_no_bg")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .padding(.top, 10)
                    .padding(.trailing, 20)
            }
            
            // --- TITLE ---
            VStack(spacing: 4) {
                Text(isCreatingAccount ? "Create an Account" : "Welcome Back!")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Find your crew today!")
                    .font(.caption)
                    .foregroundStyle(.standardSecondary)
            }
            
            // --- FORM ---
            VStack(spacing: 16) {
                VStack {
                    appleSignInButton
                    googleSignInButton
                }
                
                Text("or continue with email")
                    .font(.caption)
                    .foregroundStyle(.standardSecondary)
                
                VStack(alignment: .leading) {
                    Text("Email")
                        .font(.caption)
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.gray)
                            .padding(.leading, 10)
                        
                        TextField("Email address", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding(.vertical, 12)
                        
                    }
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(validEmail ? Color(.systemGray4) : Color("Error"), lineWidth: 2)
                    )
                    
                    if !validEmail {
                        Text("Please enter a valid email address.")
                            .font(.caption)
                            .foregroundStyle(Color("Error"))
                    }
                }
                
                if !isCreatingAccount {
                    VStack(alignment: .leading) {
                        PasswordField(
                            title: "Password",
                            placeholder: "Enter password",
                            text: $password
                        )
                        
                        Button {
                            
                        } label: {
                            Text("Forgot Password?")
                                .font(.caption)
                                .foregroundStyle(.standardSecondary)
                        }
                        
                    }
                    
                }
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundStyle(Color("Error"))
                        .font(.caption)
                }
                
                if isCreatingAccount {
                    NavigationLink {
                        SignUpView(email: $email)
                    } label: {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(email.isEmpty || !validEmail ? Color.standardSecondary : Color.brandOrange)
                            .cornerRadius(20)
                    }
                    .frame(width: 300)
                    .padding(.top, 40)
                    .disabled(email.isEmpty || !validEmail)
                } else {
                    signInButton
                        .disabled(email.isEmpty || !validEmail)
                }
                
                HStack {
                    Text(isCreatingAccount ? "Already have an account?" : "Don't have an account?")
                    Button {
                        // show password field, change to welcome back!
                        isCreatingAccount.toggle()
                        errorMessage = ""
                        
                    } label: {
                        Text(isCreatingAccount ? "Sign in" : "Sign up")
                            .foregroundStyle(.invertedPrimary)
                            .fontWeight(.semibold)
                        
                    }
                }
                .font(.system(size: 15))
            }
            .padding()
            .padding(.top, 55)
            .animation(.easeInOut, value: isCreatingAccount)
            
            Spacer()
            
        }
        .onChange(of: email) { _, _ in
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
            validEmail = emailPredicate.evaluate(with: email)
        }
        
    }
    
    private var appleSignInButton: some View {
        Button {
            Task { await authVM.signInWithGoogle() }
        } label: {
            Label {
                Text("Continue with Apple")
            } icon: {
                Image(systemName: "apple.logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            }
            .font(.system(size: 16))
            .frame(width: 300, height: 20)
            .padding()
            .foregroundColor(.invertedPrimary)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
            )
            .cornerRadius(15)
        }
    }
    
    private var googleSignInButton: some View {
        Button {
            Task { await authVM.signInWithGoogle() }
        } label: {
            Label {
                Text("Continue with Google")
            } icon: {
                Image("google_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            }
            .foregroundColor(.invertedPrimary)
            .font(.system(size: 16))
            .frame(width: 300, height: 20)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
            )
            .cornerRadius(15)
        }
    }
    
    private var signInButton: some View {
        Button {
            Task {
                await authVM.signInWithEmail(email: email, password: password)
                
                if let loginError = authVM.loginError {
                    errorMessage = loginError.message
                }
            }
        } label: {
            Text("Sign In")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("BrandOrange"))
                .cornerRadius(20)
        }
        .frame(width: 300)
        .padding(.top, 40)
    }
}

#Preview {
    SignInView()
}
