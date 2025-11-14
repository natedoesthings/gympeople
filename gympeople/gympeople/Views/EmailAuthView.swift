//
//  EmailAuthView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/12/25.
//
import SwiftUI

struct EmailAuthView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @Binding var isCreatingAccount: Bool

    var body: some View {
        VStack(spacing: 16) {
            if isCreatingAccount {
                TextField("First Name", text: $firstName)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Last Name", text: $lastName)
                    .textFieldStyle(.roundedBorder)
            }

            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            Button(isCreatingAccount ? "Create Account" : "Sign In") {
                Task {
                    if isCreatingAccount {
                        await authVM.signUpWithEmail(email: email, password: password, firstName: firstName, lastName: lastName)
                    } else {
                        await authVM.signInWithEmail(email: email, password: password)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)

            Button(isCreatingAccount ? "Already have an account? Sign In" : "Create New Account") {
                isCreatingAccount.toggle()
            }
            .font(.footnote)
        }
        .padding(.horizontal, 20)
    }
}
