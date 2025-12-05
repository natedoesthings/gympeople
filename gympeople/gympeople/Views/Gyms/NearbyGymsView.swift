//
//  Nearby.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/30/25.
//

import SwiftUI
import MapKit

struct NearbyGymsView: View {
    @ObservedObject var nearbyGymsVM: ListViewModel<Gym>
    @StateObject private var gymSearch = LocalSearchService()
    @State private var searchText: String = ""
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
                    if !nearbyGymsVM.items.isEmpty {
                        ForEach(nearbyGymsVM.items, id: \.self) { gym in
                            NavigationLink {
                                GymView(gym: gym)
                            } label: {
                                GymCard(gym: gym)
                            }
                        }
                        
                    } else {
                        Button {
                            Task {
                                await nearbyGymsVM.load()
                                await SupabaseManager.shared.insertGyms(nearbyGymsVM.items)
                            }
                        } label: {
                            Text("Load gyms...")
                        }
                    }
                    
                }
            }
            
        }
        .padding()
        .onChange(of: isFocused) { _, _ in
            if !isFocused {
                searchText = ""
                gymSearch.suggestions.removeAll()
            }
        }
        .task {
            if !nearbyGymsVM.fetched {
                await nearbyGymsVM.load()
            }
           
        }
        .refreshable {
            await nearbyGymsVM.refresh()
        }
        .listErrorAlert(vm: nearbyGymsVM, onRetry: { await nearbyGymsVM.refresh() })
        .withLocalSearchRegion(gymSearch)
    }
    
    private func findNearbyGyms() async throws -> [Gym]? {
        LOG.debug("Fetching nearby gyms")
        
        if let currentProfile = try await SupabaseManager.shared.fetchMyUserProfile().first {
            // TODO: search gyms from gyms table first, then mapkit
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
