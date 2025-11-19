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
    @Binding var location: String
    
    var next: () -> Void
    
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
                }
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 2)
                )
                
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
            .padding()
            
            Button {
                next()
            } label: {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(!location.isEmpty ? "BrandOrange" : "SecondaryColor"))
                    .cornerRadius(20)
            }
            .frame(width: 300)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 50)
            .disabled(location.isEmpty)
            
        }
        .alert(isPresented: $showLocationAlert) {
            Alert(
                title: Text("Location Not Enabled"),
                message: Text("Please enable location access for this app in Settings, or enter your city or zip manually."),
                dismissButton: .default(Text("OK"))
            )
        }

    }

    private func fetchCurrentLocation() async {
        await locationVM.reverseGeoCode()
        
        if let mapItem = locationVM.mapItem {
            self.location = mapItem.addressRepresentations?.cityWithContext ?? ""
        } else {
            // show alert if location isn't available
            showLocationAlert = true
        }
    }
}

#Preview {
    LocationStepView(location: .constant(""), next: {})
}
