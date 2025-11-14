//
//  OnboardingStep.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/13/25.
//

import SwiftUI
import CoreLocation

enum OnboardingStep: Hashable {
    case firstName
    case lastName
    case userName
    case dob
    case phone
    case location
    case gyms
    case summary
}
