//
//  LocationStepView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/13/25.
//

import SwiftUI
import CoreLocation
import MapKit

struct LocationStepView: View {
    @StateObject private var locationVM = LocationViewModel()
    @StateObject private var citySearch = CitySearchService()
    
    @Binding var latitude: Double
    @Binding var longitude: Double
    @Binding var location: String
    
    var next: () -> Void
    
    @State private var showLocationAlert: Bool = false
    @State private var isTyping = false
    
    @FocusState private var locationFieldIsFocused: Bool

    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                Text("Where do you work out?")
                    .font(.title2)
                
                HStack {
                    Image(systemName: "mappin")
                        .foregroundColor(.gray)
                        .padding(.leading, 10)
                    
                    TextField("Enter city or zip code", text: $location, onEditingChanged: { editing in
                        isTyping = editing
                        locationFieldIsFocused = editing
                    })
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding(.vertical, 12)
                        .focused($locationFieldIsFocused)
                        .onChange(of: location) { _, newValue in
                            citySearch.update(query: newValue)
                        }
                }
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 2)
                )
                
                if isTyping && !citySearch.suggestions.isEmpty {
                    List {
                        ForEach(citySearch.suggestions, id: \.self) { suggestion in
                            Button {
                                selectSuggestion(suggestion)
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
                
                if !isTyping {
                    Button {
                        Task {
                            await fetchCurrentLocation()
                        }
                    } label: {
                        HStack {
                            Text("Use my location")
                            Image(systemName: "location")
                        }
                        .foregroundStyle(.invertedPrimary)
                    }
                    .buttonStyle(.bordered)
                    .padding(.bottom)
                }
                
            }
            .padding()
            
            if !isTyping {
                Button {
                    next()
                } label: {
                    Text("Next")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(!location.isEmpty ? Color.brandOrange : Color.standardSecondary)
                        .cornerRadius(20)
                }
                .frame(width: 300)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, 50)
                .disabled(location.isEmpty || latitude == 0)
            }
            
        }
        .alert(isPresented: $showLocationAlert) {
            Alert(
                title: Text("Location Not Enabled"),
                message: Text("Please enable location access for this app in Settings, or enter your city or zip manually."),
                dismissButton: .default(Text("OK"))
            )
        }

    }
    
    private func selectSuggestion(_ suggestion: MKLocalSearchCompletion) {
        let request = MKLocalSearch.Request(completion: suggestion)
        let search = MKLocalSearch(request: request)

        search.start { response, _ in
            guard let item = response?.mapItems.first else { return }

            // Best formatted city name
            latitude = item.location.coordinate.latitude
            longitude = item.location.coordinate.longitude
            location = item.addressRepresentations?.cityWithContext ?? ""
            isTyping = false
            locationFieldIsFocused = false // hide dropdown
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

//#Preview {
//    LocationStepView(location: .constant(""), next: {})
//}
