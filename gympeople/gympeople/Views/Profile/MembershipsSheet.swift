//
//  MembershipsSheet.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/7/25.
//

import SwiftUI

// MARK: - Memberships Sheet

struct MembershipsSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var gymsVM: ListViewModel<Gym>
    @State private var selectedGym: Gym?
    
    var body: some View {
        NavigationView {
            HiddenScrollView {
                LazyVStack(spacing: 0) {
                    if gymsVM.items.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "dumbbell")
                                .font(.system(size: 60))
                                .foregroundStyle(.secondary)
                            
                            Text("No Gym Memberships")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Add your gym memberships to connect with others at your gyms")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 100)
                    } else {
                        ForEach(Array(gymsVM.items.enumerated()), id: \.element) { index, gym in
                            Button {
                                selectedGym = gym
                            } label: {
                                membershipDetailRow(gym: gym)
                            }
                            .buttonStyle(.plain)
                            
                            if index < gymsVM.items.count - 1 {
                                Divider()
                                    .padding(.leading, 72)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Gym Memberships")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .sheet(item: $selectedGym) { gym in
                MembershipVerificationSheet(gym: gym)
            }
        }
    }
    
    @ViewBuilder
    private func membershipDetailRow(gym: Gym) -> some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 20))
                .foregroundStyle(.brandOrange)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color.brandOrange.opacity(0.15))
                )
            
            // Gym details
            VStack(alignment: .leading, spacing: 8) {
                Text(gym.name ?? "Unknown Gym")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                if let address = gym.address {
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text(address)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Verification status
                HStack(spacing: 12) {
                    HStack(spacing: 6) {
                        Image(systemName: gym.verification_status!.icon)
                            .font(.system(size: 12))
                        Text(gym.verification_status!.name)
                            .font(.system(size: 13))
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(gym.verification_status!.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(gym.verification_status!.color.opacity(0.15))
                    )
                }
                .padding(.top, 4)
                
                // Info text
                Text(gym.verification_status!.displayText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 12)
    }
    
}
