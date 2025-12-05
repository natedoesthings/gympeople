//
//  LocalSearchService+Extensions.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/5/25.
//

import MapKit
import Combine

extension LocalSearchService {
    @MainActor
    func loadUserRegion() async {
        do {
            if let user = try await SupabaseManager.shared.fetchMyUserProfile().first {
                completer.region = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: user.latitude, longitude: user.longitude),
                    span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                )
            }
        } catch { LOG.error("Could not fetch user profile") }
    }
}
