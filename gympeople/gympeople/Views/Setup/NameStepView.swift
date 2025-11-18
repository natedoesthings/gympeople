//
//  NameStepView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/13/25.
//

import SwiftUI

struct FirstNameStepView: View {
    @Binding var firstName: String
    var next: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Confirm your First Name")
                .font(.title2)
            TextField("First name", text: $firstName)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            Button("Next") {
                next()
            }
            .buttonStyle(.borderedProminent)
            .disabled(firstName.isEmpty)
        }
        .padding()
    }
}

struct LastNameStepView: View {
    @Binding var lastName: String
    var next: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Confirm your Last Name")
                .font(.title2)
            TextField("Last name", text: $lastName)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            Button("Next") {
                next()
            }
            .buttonStyle(.borderedProminent)
            .disabled(lastName.isEmpty)
        }
        .padding()
    }
}

struct UserNameStepView: View {
    @Binding var userName: String
    var next: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Create a UserName")
                .font(.title2)
            TextField("Unique User Name", text: $userName)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            Button("Next") {
                next()
            }
            .buttonStyle(.borderedProminent)
            .disabled(userName.isEmpty)
        }
        .padding()
    }
}
