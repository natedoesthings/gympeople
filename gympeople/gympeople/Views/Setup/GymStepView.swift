//
//  GymStepView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/13/25.
//

import SwiftUI

struct GymStepView: View {
    @Binding var selectedGyms: [String]
    var next: () -> Void

    private let gyms = [
        "Planet Fitness",
        "LA Fitness",
        "YMCA",
        "Gold’s Gym",
        "Crunch Fitness",
        "Anytime Fitness"
    ]

    var body: some View {
        VStack(spacing: 24) {
            Text("Select your gym memberships")
                .font(.title2)
                .bold()

            List(gyms, id: \.self) { gym in
                Button {
                    toggleSelection(for: gym)
                } label: {
                    HStack {
                        Text(gym)
                        Spacer()
                        if selectedGyms.contains(gym) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)

            Button("Next") {
                next()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private func toggleSelection(for gym: String) {
        if selectedGyms.contains(gym) {
            selectedGyms.removeAll(where: { $0 == gym })
        } else {
            selectedGyms.append(gym)
        }
    }
}

#Preview {
    GymStepView(selectedGyms: .constant([]), next: { LOG.debug("Next") })
}
