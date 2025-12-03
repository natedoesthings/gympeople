//
//  GymStepView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/13/25.
//

import SwiftUI
import MapKit

struct GymStepView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var gymSearch = LocalSearchService()
    
    @State private var selectedGyms: [MKLocalSearchCompletion] = []
    let firstName: String
    let lastName: String
    let userName: String
    let email: String
    let dob: Date
    let phone: String
    let latitude: Double
    let longitude: Double
    let location: String
    
    var onDone: () -> Void
    
    @State private var searchField: String = ""
    @State private var isSubmitting = false
    @State private var submissionError: String?
    @FocusState private var isFocused: Bool
    

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
                        .onChange(of: searchField) { _, newValue in
                            gymSearch.update(query: newValue)
                        }
                }
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 2)
                )
                
                if isFocused {
                    if !gymSearch.suggestions.isEmpty {
                        VStack(spacing: 0) {
                            HiddenScrollView {
                                ForEach(gymSearch.suggestions, id: \.self) { gym in
                                    Button {
                                        toggleSelection(for: gym)
                                        searchField = ""
                                    } label: {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(gym.title)
                                                    .font(.body)
                                                    .foregroundStyle(.invertedPrimary)
                                                if !gym.subtitle.isEmpty {
                                                    Text(gym.subtitle)
                                                        .font(.caption)
                                                        .foregroundColor(.gray)
                                                        .multilineTextAlignment(.leading)
                                                }
                                            }
                                            
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
                        VStack(spacing: 0) {
                            ScrollView {
                                ForEach(selectedGyms, id: \.self) { gym in
                                    Button {
                                        toggleSelection(for: gym)
                                    } label: {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(gym.title)
                                                    .font(.body)
                                                    .foregroundStyle(.invertedPrimary)
                                                if !gym.subtitle.isEmpty {
                                                    Text(gym.subtitle)
                                                        .font(.caption)
                                                        .foregroundColor(.gray)
                                                        .multilineTextAlignment(.leading)
                                                }
                                            }
                                            
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

    private func toggleSelection(for gym: MKLocalSearchCompletion) {
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
                latitude: latitude,
                longitude: longitude,
                location: location
            )
            LOG.info("Profile saved successfully for \(email)")
            
            if !selectedGyms.isEmpty {
                LOG.info("saving gym memberships")
                await saveGymSelections()
                
            }
            
            onDone()
            
        } catch {
            LOG.error("Error saving profile: \(error)")
            submissionError = error.localizedDescription
        }
        
        isSubmitting = false
    }
    
    private func saveGymSelections() async {
        var gymPayloads: [[String: AnyEncodable]] = []

        for suggestion in selectedGyms {
            if let item = await mapItem(from: suggestion) {
                gymPayloads.append(Gym.payload(mapItem: item))
            }
        }

        guard let insertedGyms = await SupabaseManager.shared.insertGyms(gymPayloads) else {
            LOG.error("Failed to insert gyms.")
            return
        }
        
        await SupabaseManager.shared.insertGymMemberships(insertedGyms)

        LOG.info("Saved gym memberships successfully")
    }
    
    private func mapItem(from suggestion: MKLocalSearchCompletion) async -> MKMapItem? {
        let request = MKLocalSearch.Request(completion: suggestion)
        do {
            let response = try await MKLocalSearch(request: request).start()
            return response.mapItems.first
        } catch {
            return nil
        }
    }
}

// #Preview {
//    GymStepView(selectedGyms: .constant([]), next: { LOG.debug("Next") })
// }
