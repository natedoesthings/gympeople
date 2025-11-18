//
//  PasswordField.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/18/25.
//

import SwiftUI

struct PasswordField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    
    @State private var isVisible = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
            
            HStack {
                Image(systemName: "lock")
                    .foregroundColor(.gray)
                    .padding(.leading, 10)
                
                if isVisible {
                    TextField(placeholder, text: $text)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding(.vertical, 12)
                } else {
                    SecureField(placeholder, text: $text)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding(.vertical, 12)
                }
                
                Button {
                    withAnimation {
                        isVisible.toggle()
                    }
                } label: {
                    Image(systemName: isVisible ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                        .padding(.trailing, 10)
                }
            }
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 2)
            )
        }
    }
}
