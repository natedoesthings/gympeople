//
//  LocationEditingView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/25/25.
//

import SwiftUI
import MapKit

struct LocationEditingView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var locationVM = LocationViewModel()
    @StateObject private var citySearch = LocalSearchService(resultTypes: .address)
    
    @Binding var location: String
    @Binding var latitude: Double
    @Binding var longitude: Double
    
    @FocusState private var isFocused: Bool
    
    @State private var showLocationAlert: Bool = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                Text("Where do you work out?")
                    .font(.title2)
                
                HStack {
                    Image(systemName: "mappin")
                        .foregroundColor(.gray)
                        .padding(.leading, 10)
                    
                    TextField("Enter city or zip code", text: $location)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding(.vertical, 12)
                        .focused($isFocused)
                        .onChange(of: location) { _, newValue in
                            citySearch.update(query: newValue)
                        }
                    
                    Spacer()
                    
                    Button {
                        Task {
                            await fetchCurrentLocation()
                        }
                    } label: {
                        Image(systemName: "location")
                    }
                    .padding(.trailing, 10)
                }
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 2)
                )
                
                if !citySearch.suggestions.isEmpty {
                    List {
                        ForEach(citySearch.suggestions, id: \.self) { suggestion in
                            Button {
                                selectSuggestion(suggestion)
                                dismiss()
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
                
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding()
        }
        .alert(isPresented: $showLocationAlert) {
            Alert(
                title: Text("Location Not Enabled"),
                message: Text("Please enable location access for this app in Settings, or enter your city or zip manually."),
                dismissButton: .default(Text("OK"))
            )
        }
        .withLocalSearchRegion(citySearch)
    }
    
    private func selectSuggestion(_ suggestion: MKLocalSearchCompletion) {
        let request = MKLocalSearch.Request(completion: suggestion)
        let search = MKLocalSearch(request: request)

        search.start { response, _ in
            guard let item = response?.mapItems.first else { return }
            
            // Best formatted city name
            LOG.debug("lat: \(item.location.coordinate.latitude)")
            LOG.debug("lat: \(item.location.coordinate.longitude)")
            
            latitude = item.location.coordinate.latitude
            longitude = item.location.coordinate.longitude
            location = item.addressRepresentations?.cityWithContext ?? ""
            
        }
    }
    
    private func fetchCurrentLocation() async {
        await locationVM.reverseGeoCode()
        
        if let mapItem = locationVM.mapItem {
            latitude = mapItem.location.coordinate.latitude
            longitude = mapItem.location.coordinate.longitude
            self.location = mapItem.addressRepresentations?.cityWithContext ?? ""
        } else {
            // show alert if location isn't available
            showLocationAlert = true
        }
    }
    
}
