//
//  CustomTextField.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/25/25.
//

import SwiftUI

struct CustomTextField: View {
    let placeholder: String
    @Binding var field: String
    let systemName: String
    
    var body: some View {
        HStack {
            Image(systemName: systemName)
                .foregroundColor(.gray)
                .padding(.leading, 10)
            
            TextField(placeholder, text: $field)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .padding(.vertical, 12)
            .disabled(placeholder == "Email")
        }
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 2)
        )
    }
}
