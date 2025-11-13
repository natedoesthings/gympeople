//
//  NameStepView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/13/25.
//

import SwiftUI

struct NameStepView: View {
    @Binding var fullName: String
    var next: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Confirm your name")
                .font(.title2)
            TextField("Full name", text: $fullName)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            Button("Next") {
                next()
            }
            .buttonStyle(.borderedProminent)
            .disabled(fullName.isEmpty)
        }
        .padding()
    }
}
