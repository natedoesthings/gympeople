//
//  GymTagButton.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/24/25.
//

import SwiftUI

struct GymTagButton: View {
    let gymTagType: GymTagType
    
    var body: some View {
        HStack {
            switch gymTagType {
            case .none:
                Text("Add gyms")
                Image(systemName: "plus")
            case .gym(let gym):
                Text("\(gym)")
            case .plus:
                Image(systemName: "plus")
            }
            
        }
        .padding(5)
        .font(.caption)
        .foregroundColor(Color.brandOrange)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.brandOrange, lineWidth: 2)
        )
    }
}
