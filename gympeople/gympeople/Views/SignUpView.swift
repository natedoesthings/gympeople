//
//  SignUpView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/18/25.
//
import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Binding var email: String
    @State var password: String = ""
    @State var confirmPassword: String = ""
    @State var firstName: String = ""
    @State var lastName: String = ""
    
    @State private var validFirstName: Bool = true
    @State private var validLastName: Bool = true
    @State private var validPassword: Bool = true
    @State private var validConfirmPassword: Bool = true
    
    @State private var showPassword: Bool = false
    @State private var showConfirmPassword: Bool = false
    
    var isFormValid: Bool {
        validFirstName && validLastName && validPassword && validConfirmPassword
    }
    
    var body: some View {
            VStack(spacing: 24) {
                // --- TOP RIGHT LOGO ---
                HStack {
                    Spacer()
                    Image("gympeople_light_no_bg")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .padding(.top, 10)
                        .padding(.trailing, 20)
                }
                
                // --- TITLE ---
                Text("Complete Account Setup")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                
                // --- FORM ---
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("First Name")
                            .font(.caption)
                        HStack {
                            Image(systemName: "person")
                                .foregroundColor(.gray)
                                .padding(.leading, 10)
                            
                            TextField("First Name", text: $firstName)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .padding(.vertical, 12)
                        }
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 2)
                        )
                        
                        if !validFirstName {
                            Text("First name is empty.")
                                .font(.caption)
                                .foregroundStyle(Color("Error"))
                        }
                        
                        Text("Last Name")
                            .font(.caption)
                        HStack {
                            Image(systemName: "person.text.rectangle")
                                .foregroundColor(.gray)
                                .padding(.leading, 10)
                            
                            TextField("Last Name", text: $lastName)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .padding(.vertical, 12)
                        }
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 2)
                        )
                        
                        if !validLastName {
                            Text("Last name is empty.")
                                .font(.caption)
                                .foregroundStyle(Color("Error"))
                        }
                        
                        PasswordField(
                            title: "Password",
                            placeholder: "Enter password",
                            text: $password
                        )

                        
                        if !validPassword {
                            Text("Password needs to contain at least 8 characters, one symbol, one uppercase, and one lowercase character.")
                                .font(.caption)
                                .foregroundStyle(Color("Error"))
                                .multilineTextAlignment(.leading)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                                
                        }
                        
                        PasswordField(
                            title: "Confirm Password",
                            placeholder: "Re-enter password",
                            text: $confirmPassword
                        )

                        if !validConfirmPassword {
                            Text("Passwords do not match.")
                                .font(.caption)
                                .foregroundStyle(Color("Error"))
                        }
                        
                    }
                    
                    
                    Button {
                        Task {
                            checkForm()
                            
                            if isFormValid {
                                LOG.debug("Form is valid")
                                await authVM.signUpWithEmail(email: email, password: password, firstName: firstName, lastName: lastName)
                            } else {
                                LOG.debug("Form is invalid")
                            }
                            
                            
                        }
                    } label: {
                        Text("Sign Up")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("BrandOrange"))
                            .cornerRadius(20)
                    }
                    .frame(width: 300)
                    .padding(.vertical, 40)

                }
                .padding()
                .padding(.top, 50)
                
                Spacer()
                
            }
        }
    
    private func checkForm() {
        validFirstName = !firstName.isEmpty
        validLastName = !lastName.isEmpty
        
        validPassword = isValidPassword(password)
        validConfirmPassword = password == confirmPassword
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        // At least 8 chars
        guard password.count >= 8 else { return false }

        var hasUpper = false
        var hasLower = false
        var hasSymbol = false
        
        for char in password {
            if char.isUppercase {
                hasUpper = true
            } else if char.isLowercase {
                hasLower = true
            } else if char.isNumber {
                // ignore numbers
                continue
            } else {
                hasSymbol = true
            }
        }
        
        return hasUpper && hasLower && hasSymbol
    }
}

#Preview {
    SignUpView(email: .constant(""))
}
