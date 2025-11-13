//
//  DOBStepView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/13/25.
//

import SwiftUI

struct DOBStepView: View {
    @Binding var dob: Date
    var next: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("When’s your birthday?")
                .font(.title2)
                .bold()

            DatePicker("Select Date of Birth", selection: $dob, displayedComponents: .date)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding()

            Button("Next") {
                next()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    DOBStepView(dob: .constant(Date()), next: { print("Next") })
}
