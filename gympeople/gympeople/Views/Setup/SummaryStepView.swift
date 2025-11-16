//
//  SummaryStepView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/13/25.
//

import SwiftUI
import CoreLocation

struct SummaryStepView: View {
    @EnvironmentObject var authVM: AuthViewModel

    let firstName: String
    let lastName: String
    let userName: String
    let email: String
    let dob: Date
    let phone: String
    let location: String
    let gyms: [String]

    @State private var isSubmitting = false
    @State private var submissionError: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Review Your Info")
                    .font(.title)
                    .bold()

                Group {
                    Text("First Name: \(firstName)")
                    Text("Last Name: \(lastName)")
                    Text("User Name: \(userName)")
                    Text("Email: \(email)")
                    Text("DOB: \(dob.formatted(date: .long, time: .omitted))")
                    Text("Phone: \(phone)")
                    Text("Location: \(location)")
                    Text("Gyms: \(gyms.isEmpty ? "None" : gyms.joined(separator: ", "))")
                }
                .padding(.vertical, 2)

                if let submissionError {
                    Text("\(submissionError)")
                        .foregroundColor(.red)
                }

                Button(isSubmitting ? "Submitting..." : "Submit") {
                    Task { await handleSubmit() }
                }
                .disabled(isSubmitting)
                .buttonStyle(.borderedProminent)
                .padding(.top)
            }
            .padding()
        }
    }

    private func handleSubmit() async {
        isSubmitting = true
        submissionError = nil
        do {
            try await SupabaseManager.shared.saveUserProfile(
                firstName: firstName,
                lastName: lastName,
                userName: userName,
                email: email,
                dob: dob,
                phone: phone,
                location: location,
                gyms: gyms
            )
            print("Profile saved successfully")
            authVM.needsOnboarding = false
        } catch {
            print("Error saving profile:", error)
            submissionError = error.localizedDescription
        }
        isSubmitting = false
    }
}


//#Preview {
//    SummaryStepView(
//        name: "Nathanael Tesfaye",
//        email: "nathanael@example.com",
//        dob: Date(),
//        phone: "615-555-9999",
//        location: CLLocationCoordinate2D(latitude: 36.1627, longitude: -86.7816),
//        manualLocation: "Nashville, TN",
//        gyms: ["YMCA"],
//    )
//}
