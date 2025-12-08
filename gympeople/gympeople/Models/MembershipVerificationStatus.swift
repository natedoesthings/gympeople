//
//  MembershipVerificationStatus.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/7/25.
//

import SwiftUI

enum MembershipVerificationStatus: String, Codable, CaseIterable {
    case unverified
    case verified
    case pending
    
    var name: String {
        switch self {
        case .unverified: return "Unverified"
        case .verified: return "Verified"
        case .pending: return "Pending"
        }
    }
    var icon: String {
        switch self {
        case .unverified: return "x.circle"
        case .verified: return "checkmark.circle"
        case .pending: return "hourglass"
        }
    }
    
    var color: Color {
        switch self {
        case .unverified: return .red
        case .verified: return .green
        case .pending: return .orange
        }
    }
    
    var displayText: String {
        switch self {
        case .unverified: return "Please verify your membership for continued access for this gym."
        case .verified: return "Your membership has been verified!"
        case .pending: return "We're reviewing your membership. This usually takes 1-2 business days."
        }
    }
}
