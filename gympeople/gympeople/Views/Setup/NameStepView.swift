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
                
                HStack {
                    Image(systemName: "person")
                        .foregroundColor(.gray)
                        .padding(.leading, 10)
                    
                    TextField("First Name", text: $firstName)
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
                    .background(Color(validFirstName ? "BrandOrange" : "SecondaryColor"))
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
                
                HStack {
                    Image(systemName: "person.text.rectangle")
                        .foregroundColor(.gray)
                        .padding(.leading, 10)
                    
                    TextField("Last Name", text: $lastName)
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
                    .background(Color(validLastName ? "BrandOrange" : "SecondaryColor"))
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
    var validUserName: Bool {
        !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
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
                }
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 2)
                )
                
                if !validUserName {
                    Text("Username is taken.")
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
                    .background(Color(validUserName ? "BrandOrange" : "SecondaryColor"))
                    .cornerRadius(20)
            }
            .frame(width: 300)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 50)
            .disabled(!validUserName)
        }
        
    }
}

#Preview {
    UserNameStepView(userName: .constant(""), next: {})
}
