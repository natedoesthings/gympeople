//
//  EmailStepView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/13/25.
//

import SwiftUI

struct EmailStepView: View {
    @Binding var email: String
    var next: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Confirm your email")
                .font(.title2)
            TextField("Email address", text: $email)
                .keyboardType(.emailAddress)
                .textFieldStyle(.roundedBorder)
                .padding()

            Button("Next") {
                next()
            }
            .buttonStyle(.borderedProminent)
            .disabled(email.isEmpty)
        }
        .padding()
    }
}

#Preview {
    EmailStepView(
        email: .constant(""),
        next: { print("Next tapped") }
    )
}

