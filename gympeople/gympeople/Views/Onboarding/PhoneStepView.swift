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
                
                HStack {
                    Image(systemName: "phone")
                        .foregroundColor(.gray)
                        .padding(.leading, 10)
                    
                    TextField("e.g. 615-555-1234", text: $phone)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding(.vertical, 12)
                }
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 2)
                )
                
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
