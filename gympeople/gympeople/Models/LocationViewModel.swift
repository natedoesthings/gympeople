//
//  LocationViewModel.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/14/25.
//

import SwiftUI
import CoreLocation
import Combine
import MapKit

class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var address: MKAddress?
    private var location: CLLocation?
    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    // Delegate method called when location updates arrive
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.last {
            DispatchQueue.main.async {
                self.location = loc
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func reverseGeoCode() async {
        if let location = self.location {
            if let request = MKReverseGeocodingRequest(location: location) {
                do {
                    let mapItems = try await request.mapItems
                    let mapItem = mapItems.first
                    self.address = mapItem?.address ?? nil
                    
                } catch  {
                    print("Reverse Geocoding Error:", error)
                }
            }
        }
        
    }
}
