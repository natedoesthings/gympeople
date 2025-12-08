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
        VStack(spacing: 0) {
            // Search Section
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                    
                    TextField("Search by city or zip code", text: $searchText)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .focused($isFocused)
                        .onChange(of: searchText) { _, newValue in
                            gymSearch.update(query: newValue)
                        }
                    
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                            gymSearch.suggestions.removeAll()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                
                // Search Suggestions
                if !gymSearch.suggestions.isEmpty {
                    VStack(spacing: 0) {
                        ForEach(gymSearch.suggestions.prefix(5), id: \.self) { suggestion in
                            NavigationLink {
                                GymSuggestionView(suggestion: suggestion)
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundStyle(Color("BrandOrange"))
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(suggestion.title)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                        
                                        if !suggestion.subtitle.isEmpty {
                                            Text(suggestion.subtitle)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                            
                            if suggestion != gymSearch.suggestions.prefix(5).last {
                                Divider()
                                    .padding(.leading, 48)
                            }
                        }
                    }
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 24)
            .background(Color(.systemBackground))
            
            Divider()
            
            // Gyms List
            HiddenScrollView {
                LazyVStack(spacing: 16) {
                    if !nearbyGymsVM.items.isEmpty {
                        ForEach(nearbyGymsVM.items, id: \.self) { gym in
                            NavigationLink {
                                GymView(gym: gym)
                            } label: {
                                GymCard(gym: gym)
                            }
                        }
                    } else if !nearbyGymsVM.isLoading {
                        VStack(spacing: 16) {
                            Image(systemName: "dumbbell.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(Color("BrandOrange").opacity(0.6))
                            
                            Text("No gyms found nearby")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("Try adjusting your search location")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 80)
            }
        }
        .overlay {
            if nearbyGymsVM.isLoading {
                VStack {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Finding gyms...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground).opacity(0.8))
            }
        }
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
