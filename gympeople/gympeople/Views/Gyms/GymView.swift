//
//  GymView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/28/25.
//

import SwiftUI
import MapKit

struct GymSuggestionView: View {
    let suggestion: MKLocalSearchCompletion
    @State private var gym: MKMapItem?

    var body: some View {
        VStack {
            if let gym = gym {
                GymView(gym: gym)
                
            } else {
                ProgressView()
            }
        }
        .task {
            self.gym = await selectSuggestion(suggestion)
        }
    }
    
    func selectSuggestion(_ suggestion: MKLocalSearchCompletion) async -> MKMapItem? {
        let request = MKLocalSearch.Request(completion: suggestion)
        let search = MKLocalSearch(request: request)
        
        do {
            let response = try await search.start()
            return response.mapItems.first
        } catch {
            print("Local search failed:", error)
            return nil
        }
    }
}


struct GymView: View {
    let gym: MKMapItem
    
    var body: some View {
        Text(gym.name ?? "Unknown Gym")
    }
}
