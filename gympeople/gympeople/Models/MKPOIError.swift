//
//  Untitled.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/30/25.
//

import Foundation

enum MKPOIError: LocalizedError, Identifiable {
    case incorrectCategory
    
    var id: String { localizedDescription }
    
    var errorDescription: String? {
        switch self {
        case .incorrectCategory:
            return "Please select a fitness location (like a gym or fitness center)."
        }
    }
}

