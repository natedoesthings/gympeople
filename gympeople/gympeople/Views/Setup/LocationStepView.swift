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
        VStack(spacing: 24) {
            Text("Where do you work out?")
                .font(.title2)
                .bold()

            TextField("Enter city or zip", text: $location)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            Button("Use My Location") {
                Task  {
                    await fetchCurrentLocation()
                }
            }
            .buttonStyle(.bordered)
            .padding(.bottom)

            Button("Next") {
                next()
            }
            .buttonStyle(.borderedProminent)
            .disabled(locationVM.address == nil && location.isEmpty)
        }
        .padding()
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
        
        if let address = locationVM.address {
            // TODO: set manuallocation to reversegeocoded city
            print("full", address.fullAddress)
            print("short", address.shortAddress)
            self.location = ""
        } else {
            // show alert if location isn't available
            showLocationAlert = true
        }
    }
}

