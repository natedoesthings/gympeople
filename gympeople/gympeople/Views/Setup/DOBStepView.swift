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
        ZStack {
            VStack(spacing: 24) {
                Text("When’s your birthday?")
                    .font(.title2)
                
                DatePicker("Select Date of Birth", selection: $dob, displayedComponents: .date)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding()
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
                    .background(Color("BrandOrange"))
                    .cornerRadius(20)
            }
            .frame(width: 300)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 50)
        }
    }
}

#Preview {
    DOBStepView(dob: .constant(Date()), next: {})
}
