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
    
    // NEW
    var onCancel: () -> Void
    var onFinished: () -> Void

    var body: some View {
        ZStack {
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
                            GymStepView(
                                selectedGyms: $gymMemberships,
                                firstName: firstName,
                                lastName: lastName,
                                userName: userName,
                                email: email,
                                dob: dob,
                                phone: phone,
                                location: location,
                                onDone: { onFinished() }
                            )
                        default:
                            EmptyView()
                        }
                    }
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Back to Login") {
                                onCancel()
                            }
                        }
                    }
            }
            
            if path.last != .gyms {
                HStack {
                    Spacer()
                    Image("gympeople_no_bg")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .padding(.top, 55)
                        .padding(.trailing, 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
            

        }
        
    }
    
}

#Preview {
    OnboardingView(firstName: .constant(""), lastName: .constant(""), email: .constant(""), onCancel: {}, onFinished: {})
}
