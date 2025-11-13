//
//  PhoneStepView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/13/25.
//

import SwiftUI

struct PhoneStepView: View {
    @Binding var phone: String
    var next: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("Add your phone number")
                .font(.title2)
                .bold()

            TextField("e.g. 615-555-1234", text: $phone)
                .keyboardType(.phonePad)
                .textFieldStyle(.roundedBorder)
                .padding()

            Button("Next") {
                next()
            }
            .buttonStyle(.borderedProminent)
            .disabled(phone.isEmpty)
        }
        .padding()
    }
}

#Preview {
    PhoneStepView(phone: .constant(""), next: { print("Next") })
}

