//
//  LocationStepView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/13/25.
//

import SwiftUI
import CoreLocation

struct LocationStepView: View {
    @StateObject private var locationVM = LocationViewModel()
    
    @Binding var location: CLLocationCoordinate2D?
    @Binding var manualLocation: String
    var next: () -> Void
    
    @State private var showLocationAlert: Bool = false

    var body: some View {
        VStack(spacing: 24) {
            Text("Where do you work out?")
                .font(.title2)
                .bold()

            TextField("Enter city or zip", text: $manualLocation)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            Button("Use My Location") {
                fetchCurrentLocation()
            }
            .buttonStyle(.bordered)
            .padding(.bottom)

            Button("Next") {
                next()
            }
            .buttonStyle(.borderedProminent)
            .disabled(location == nil && manualLocation.isEmpty)
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

    private func fetchCurrentLocation() {
        self.location = locationVM.location
        if self.location == nil {
            // show alert if location isn't available
            showLocationAlert = true
        } else {
            print("Latitude:", self.location?.latitude ?? 0)
            print("Longitude:", self.location?.longitude ?? 0)
            // TODO: set manuallocation to reversegeocoded city
            self.manualLocation = ""
        }
    }
}

#Preview {
    LocationStepView(location: .constant(nil), manualLocation: .constant(""), next: { print("Next") })
}
