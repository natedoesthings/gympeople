//
//  NameStepView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/13/25.
//

import SwiftUI

struct FirstNameStepView: View {
    @Binding var firstName: String
    var validFirstName: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var next: () -> Void

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Confirm your First Name.")
                    .font(.title2)
                
                CustomTextField(placeholder: "First Name", field: $firstName, systemName: "person")
                
                if !validFirstName {
                    Text("First name is empty.")
                        .font(.caption)
                        .foregroundStyle(Color("Error"))
                }
                
            }
            .padding()
            
            Button {
                next()
            } label: {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(validFirstName ? Color.brandOrange : Color.standardSecondary)
                    .cornerRadius(20)
            }
            .frame(width: 300)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 50)
            .disabled(!validFirstName)
        }
        
    }
}

struct LastNameStepView: View {
    @Binding var lastName: String
    var validLastName: Bool {
        !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var next: () -> Void

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Confirm your Last Name.")
                    .font(.title2)
                
                CustomTextField(placeholder: "Last Name", field: $lastName, systemName: "person.text.rectangle")
                
                if !validLastName {
                    Text("Last name is empty.")
                        .font(.caption)
                        .foregroundStyle(Color("Error"))
                }
                
            }
            .padding()
            
            Button {
                next()
            } label: {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(validLastName ? Color.brandOrange : Color.standardSecondary)
                    .cornerRadius(20)
            }
            .frame(width: 300)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 50)
            .disabled(!validLastName)
        }
        
    }
}

struct UserNameStepView: View {
    @Binding var userName: String
    
    @State private var validUserName: Bool = false
    @State private var checkingUsername: Bool = false
    @FocusState private var userNameFieldIsFocused: Bool
    
    var next: () -> Void

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Create your Username.")
                    .font(.title2)
                
                HStack {
                    Image(systemName: "person")
                        .foregroundColor(.gray)
                        .padding(.leading, 10)
                    
                    TextField("Username", text: $userName)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding(.vertical, 12)
                        .focused($userNameFieldIsFocused)
                    
                    Spacer()
                    
                    if checkingUsername {
                        ProgressView()
                            .padding(.trailing, 10)
                    } else {
                        // TODO: https://github.com/natedoesthings/gympeople/issues/23
                        Image(systemName: validUserName ? "checkmark.circle.fill" : "x.circle.fill")
                            .padding(.trailing, 10)
                            .foregroundStyle(validUserName ? .success : .error)
                    }
                    
                }
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 2)
                )
                
                if !validUserName {
                    Text("Username unavailable.")
                        .font(.caption)
                        .foregroundStyle(Color("Error"))
                }
                
            }
            .padding()
            
            Button {
                next()
            } label: {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(validUserName ? Color.brandOrange : Color.standardSecondary)
                    .cornerRadius(20)
            }
            .frame(width: 300)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 50)
            .disabled(!validUserName)
        }
        .onChange(of: userNameFieldIsFocused) { _, _ in
            Task {
                checkingUsername = true
                validUserName = await SupabaseManager.shared.checkUserName(userName: userName) && !userName.isEmpty
                checkingUsername = false
            }
        }
    }
}

#Preview {
    UserNameStepView(userName: .constant(""), next: {})
}
