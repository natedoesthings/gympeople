//
//  GymEditingView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/25/25.
//

import SwiftUI
import MapKit

struct GymEditingView: View {
    let manager = SupabaseManager.shared
    
    @StateObject private var gymSearch = LocalSearchService()
    @Binding var gym_memberships: [Gym]
    @State private var selectedGyms: [MKLocalSearchCompletion] = []
    
    @State private var searchField: String = ""
    
    @FocusState private var isFocused: Bool
    
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
                VStack(spacing: 0) {
                    ScrollView {
                        // current memberships
                        if !gym_memberships.isEmpty {
                            ForEach(gym_memberships, id: \.self) { gym in
                                Button {
                                    if gym_memberships.contains(gym) {
                                        gym_memberships.removeAll(where: { $0 == gym })
                                    }
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(gym.name ??  "Gym")
                                                .font(.body)
                                                .foregroundStyle(.invertedPrimary)
                                        
                                            Text(gym.address ?? "Address")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                                .multilineTextAlignment(.leading)
                                            
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(Color.brandOrange)
                                        
                                    }
                                }
                                Divider()
                                
                            }
                        }
                        // any newley selected memberships
                        if !selectedGyms.isEmpty {
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
                    }
                }
                .frame(height: 300)
            }
            
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
        .onDisappear {
            Task {
                await updateMemberships()
            }
        }
    }
    
    private func updateMemberships() async {
        var payload: [[String: AnyEncodable]] = []
        
        // any newly added memberships
        for suggestion in selectedGyms {
            if let item = await mapItem(from: suggestion) {
                payload.append(Gym.payload(mapItem: item))
            }
        }
        
        // existing memberships
        for membership in gym_memberships {
            payload.append(Gym.payload(gym: membership))
        }
        
        // inserting gyms
        guard let insertedGyms = await SupabaseManager.shared.insertGyms(payload) else {
            LOG.error("Failed to insert gyms.")
            return
        }
        
        // syncing gym memberships for user
        await manager.syncGymMemberships(gyms: insertedGyms)
    }
    
    private func toggleSelection(for gym: MKLocalSearchCompletion) {
        if selectedGyms.contains(gym) {
            selectedGyms.removeAll(where: { $0 == gym })
        } else {
            selectedGyms.append(gym)
        }
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
