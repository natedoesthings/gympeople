//
//  LocalSearchService.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/19/25.
//

import MapKit
import Combine

class LocalSearchService: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var suggestions: [MKLocalSearchCompletion] = []
    
    private let completer: MKLocalSearchCompleter
    
    init(resultTypes: MKLocalSearchCompleter.ResultType = .pointOfInterest) {
        self.completer = MKLocalSearchCompleter()
        super.init()
        
        completer.delegate = self
        completer.resultTypes = resultTypes
    }
    
    func update(query: String) {
        completer.queryFragment = query
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.suggestions = completer.results
    }
}
