//
//  OnboardingView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/13/25.
//

import SwiftUI
import CoreLocation

struct OnboardingView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var path: [OnboardingStep] = []
    
    // Collected data
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var email: String
    @State private var userName: String = ""
    @State private var dob: Date = Date()
    @State private var phone: String = ""
    @State private var location: String = ""
    @State private var gymMemberships: [String] = []

    var body: some View {
        NavigationStack(path: $path) {
            FirstNameStepView(firstName: $firstName, next: { path.append(.lastName) })
                .navigationDestination(for: OnboardingStep.self) { step in
                    switch step {
                    case .lastName:
                        LastNameStepView(lastName: $lastName, next: { path.append(.userName) })
                    case .userName:
                        UserNameStepView(userName: $userName, next: { path.append(.dob) })
                    case .dob:
                        DOBStepView(dob: $dob, next: { path.append(.phone) })
                    case .phone:
                        PhoneStepView(phone: $phone, next: { path.append(.location) })
                    case .location:
                        LocationStepView(location: $location, next: { path.append(.gyms) })
                    case .gyms:
                        GymStepView(selectedGyms: $gymMemberships, next: { path.append(.summary) })
                    case .summary:
                        SummaryStepView(
                            firstName: firstName,
                            lastName: lastName,
                            userName: userName,
                            email: email,
                            dob: dob,
                            phone: phone,
                            location: location,
                            gyms: gymMemberships,
                        )
                    default:
                        EmptyView()
                    }
                }
                .navigationTitle("Onboarding")
        }
        Button("Sign Out") {
            Task { await authVM.signOut() }
        }
        .foregroundColor(.red)
    }
    
    
}
