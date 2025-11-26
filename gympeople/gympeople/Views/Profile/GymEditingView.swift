//
//  GymEditingView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/25/25.
//

import SwiftUI

struct GymEditingView: View {
    @State private var searchField: String = ""
    @Binding var gym_memberships: [String]
    @FocusState private var isFocused: Bool
    
    private var filteredGyms: [String] {
        let query = searchField.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty { return GYMS }
        return GYMS.filter { $0.localizedCaseInsensitiveContains(query) }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Find your gym memberships")
                .font(.title2)
            
            HStack {
                Image(systemName: "dumbbell")
                    .foregroundColor(.gray)
                    .padding(.leading, 10)
                
                TextField("Enter a gym...", text: $searchField)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.vertical, 12)
                    .focused($isFocused)
            }
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 2)
            )
            
            if isFocused {
                if !filteredGyms.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        HiddenScrollView {
                            ForEach(filteredGyms, id: \.self) { gym in
                                Button {
                                    toggleSelection(for: gym)
                                    // Optional: clear search after selecting
                                    searchField = ""
                                } label: {
                                    HStack {
                                        Text(gym)
                                            .foregroundStyle(.invertedPrimary)
                                        Spacer()
                                        if gym_memberships.contains(gym) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(Color.brandOrange)
                                        }
                                    }
                                }
                                Divider()
                            }
                        }
                        .frame(height: 420)
                        
                    }
                }
            } else {
                if !gym_memberships.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        HiddenScrollView {
                            ForEach(gym_memberships, id: \.self) { gym in
                                Button {
                                    toggleSelection(for: gym)
                                } label: {
                                    HStack {
                                        Text(gym)
                                            .foregroundStyle(.invertedPrimary)
                                        Spacer()
                                        if gym_memberships.contains(gym) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(Color.brandOrange)
                                        }
                                    }
                                }
                                Divider()
                            }
                        }
                        .frame(height: 300)
                        
                    }
                }
            }
            
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
    }
    
    private func toggleSelection(for gym: String) {
        if gym_memberships.contains(gym) {
            gym_memberships.removeAll(where: { $0 == gym })
        } else {
            gym_memberships.append(gym)
        }
    }
}
