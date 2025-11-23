//
//  GymStepView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/13/25.
//

import SwiftUI

struct GymStepView: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    @Binding var selectedGyms: [String]
    let firstName: String
    let lastName: String
    let userName: String
    let email: String
    let dob: Date
    let phone: String
    let location: String
    
    var onDone: () -> Void
    
    @State private var searchField: String = ""
    @State private var isSubmitting = false
    @State private var submissionError: String?
    @FocusState private var isFocused: Bool
    
    private var filteredGyms: [String] {
        let query = searchField.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty { return GYMS }
        return GYMS.filter { $0.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        ZStack {
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
                            ScrollView {
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
                                            if selectedGyms.contains(gym) {
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
                    if !selectedGyms.isEmpty {
                        VStack(alignment: .leading, spacing: 0) {
                            ScrollView {
                                ForEach(selectedGyms, id: \.self) { gym in
                                    Button {
                                        toggleSelection(for: gym)
                                    } label: {
                                        HStack {
                                            Text(gym)
                                                .foregroundStyle(.invertedPrimary)
                                            Spacer()
                                            if selectedGyms.contains(gym) {
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
            .padding(.top, 80)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            
            if !isFocused {
                Button {
                    Task { await handleSubmit() }
                } label: {
                    Text("Done")
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
            
            // TODO: Fix skip button 
            Button {
                Task {
                    selectedGyms = []
                    await handleSubmit()
                }
            } label: {
                Text("Skip")
                    .foregroundStyle(Color.brandOrange)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            
        }
        .padding()
    }

    private func toggleSelection(for gym: String) {
        if selectedGyms.contains(gym) {
            selectedGyms.removeAll(where: { $0 == gym })
        } else {
            selectedGyms.append(gym)
        }
    }
    
    private func handleSubmit() async {
        isSubmitting = true
        submissionError = nil
        do {
            try await SupabaseManager.shared.saveUserProfile(
                firstName: firstName,
                lastName: lastName,
                userName: userName,
                email: email,
                dob: dob,
                phone: phone,
                location: location,
                gyms: selectedGyms
            )
            LOG.info("Profile saved successfully for \(email)")
            
            onDone()
        } catch {
            LOG.error("Error saving profile: \(error)")
            submissionError = error.localizedDescription
        }
        isSubmitting = false
    }
    
}

// #Preview {
//    GymStepView(selectedGyms: .constant([]), next: { LOG.debug("Next") })
// }
