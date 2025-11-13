//
//  LocationStepView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/13/25.
//

import SwiftUI
import CoreLocation

struct LocationStepView: View {
    @Binding var location: CLLocationCoordinate2D?
    @Binding var manualLocation: String
    var next: () -> Void

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
    }

    private func fetchCurrentLocation() {
        let manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        if let loc = manager.location?.coordinate {
            self.location = loc
        }
    }
}

#Preview {
    LocationStepView(location: .constant(nil), manualLocation: .constant(""), next: { print("Next") })
}
