//
//  GymsView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/26/25.
//

import SwiftUI
import MapKit

struct GymsView: View {
    @StateObject private var gymSearch = LocalSearchService(resultTypes: .pointOfInterest)
    @State private var searchText: String = ""
    @State private var gyms: [MKMapItem]?
    @FocusState private var isFocused: Bool
    
    
    var body: some View {
        NavigationStack {
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
                
                ScrollView {
                    LazyVStack {
                        if let gyms = gyms {
                            ForEach(gyms, id: \.self) { gym in
                                NavigationLink {
                                    GymView(gym: gym)
                                } label: {
                                    Text(gym.name ?? "Unknown gym")
                                }
                                
                            }
                        }
                        
                    }
                }
                
            }
            .padding()
            .onAppear {
                Task {
                    gyms = try await findNearbyGyms()
                }
            }
            .onChange(of: isFocused) { _,_ in
                if !isFocused {
                    searchText = ""
                    gymSearch.suggestions.removeAll()
                }
            }
        }
        
    }
    

    
    private func findNearbyGyms() async throws -> [MKMapItem]? {
        if let currentProfile = try await SupabaseManager.shared.fetchMyUserProfile() {
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
            
            return response.mapItems
        }
        
        return nil
    }

}


#Preview {
    GymsView()
}
