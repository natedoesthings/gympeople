//
//  Nearby.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/30/25.
//

import SwiftUI
import MapKit

struct NearbyGymsView: View {
    @StateObject private var gymSearch = LocalSearchService()
    @State private var searchText: String = ""
    @Binding var gyms: [Gym]?
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "mappin")
                    .foregroundColor(.gray)
                    .padding(.leading, 10)
                
                TextField("Enter city or zip code", text: $searchText)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.vertical, 12)
                    .focused($isFocused)
                    .onChange(of: searchText) { _, newValue in
                        gymSearch.update(query: newValue)
                    }
            }
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 2)
            )
            
            if !gymSearch.suggestions.isEmpty {
                List {
                    ForEach(gymSearch.suggestions, id: \.self) { suggestion in
                        NavigationLink {
                            GymSuggestionView(suggestion: suggestion)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(suggestion.title)
                                    .font(.body)
                                if !suggestion.subtitle.isEmpty {
                                    Text(suggestion.subtitle)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
                .frame(height: 200) // dropdown height
                .listStyle(.plain)
            }
            
            HiddenScrollView {
                LazyVStack {
                    if let gyms = gyms, !gyms.isEmpty {
                        ForEach(gyms, id: \.self) { gym in
                            NavigationLink {
                                GymView(gym: gym)
                            } label: {
                                GymCard(gym: gym)
                            }
                        }
                        
                    } else {
                        Button {
                            Task {
                                gyms = try await findNearbyGyms()
                                
                                guard let gyms = gyms else { return }
                                await SupabaseManager.shared.insertGyms(gyms)
                            }
                        } label: {
                            Text("Load gyms...")
                        }
                    }
                    
                }
            }
            
        }
        .padding()
        .onChange(of: isFocused) { _,_ in
            if !isFocused {
                searchText = ""
                gymSearch.suggestions.removeAll()
            }
        }
    }
    
    private func findNearbyGyms() async throws -> [Gym]? {
        LOG.debug("Fetching nearby gyms")
        
        if let currentProfile = await SupabaseManager.shared.fetchMyUserProfile() {
            //TODO: search gyms from gyms table first, then mapkit
            let coordinate = CLLocationCoordinate2D(latitude: currentProfile.latitude, longitude: currentProfile.longitude)
            
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = "gym"
            request.region = MKCoordinateRegion(
                center: coordinate,
                latitudinalMeters: 5000,   // 5 km radius
                longitudinalMeters: 5000
            )
            
            let search = MKLocalSearch(request: request)
            let response = try await search.start()
            
            var gyms: [Gym] = []
            
            for item in response.mapItems {
                gyms.append(Gym.from(mapItem: item))
            }
            
            return gyms
        }
        
        return nil
    }
    
}
