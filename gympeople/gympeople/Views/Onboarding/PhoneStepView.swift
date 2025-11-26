//
//  PhoneStepView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/13/25.
//

import SwiftUI

struct PhoneStepView: View {
    @Binding var phone: String
    var validPhoneNumber: Bool {
        !phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var next: () -> Void

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Add your phone number.")
                    .font(.title2)
                
                CustomTextField(placeholder: "e.g. 615-555-1234", field: $phone, systemName: "phone")
                
                if !validPhoneNumber {
                    Text("Phone number is empty.")
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
                    .background(validPhoneNumber ? Color.brandOrange : Color.standardSecondary)
                    .cornerRadius(20)
            }
            .frame(width: 300)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 50)
            .disabled(!validPhoneNumber)
        }
        
    }
}
