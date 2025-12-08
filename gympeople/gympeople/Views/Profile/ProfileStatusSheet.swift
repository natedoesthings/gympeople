//
//  ProfileStatusSheet.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/7/25.
//

import SwiftUI

// MARK: - Profile Status Sheet

struct ProfileStatusSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var userProfile: UserProfile
    @State private var selectedStatus: Bool
    @State private var isSaving: Bool = false
    
    init(userProfile: Binding<UserProfile>) {
        _userProfile = userProfile
        _selectedStatus = State(initialValue: userProfile.wrappedValue.is_private)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Options
                VStack(spacing: 10) {
                    // Public option
                    Button {
                        selectedStatus = false
                    } label: {
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 8) {
                                    Image(systemName: "globe")
                                        .font(.title3)
                                        .foregroundStyle(.blue)
                                    
                                    Text("Public")
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                }
                                
                                Text("Anyone can see your profile, posts, and gym memberships")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                            
                            Spacer()
                            
                            if !selectedStatus {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.brandOrange)
                            } else {
                                Image(systemName: "circle")
                                    .font(.title2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedStatus ? Color(.systemGray6) : Color.brandOrange.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedStatus ? Color.clear : Color.brandOrange, lineWidth: 2)
                        )
                    }
                    
                    // Private option
                    Button {
                        selectedStatus = true
                    } label: {
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 8) {
                                    Image(systemName: "lock.fill")
                                        .font(.title3)
                                        .foregroundStyle(.purple)
                                    
                                    Text("Private")
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                }
                                
                                Text("Only people you approve can see your profile and posts")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                            
                            Spacer()
                            
                            if selectedStatus {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.brandOrange)
                            } else {
                                Image(systemName: "circle")
                                    .font(.title2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(!selectedStatus ? Color(.systemGray6) : Color.brandOrange.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(!selectedStatus ? Color.clear : Color.brandOrange, lineWidth: 2)
                        )
                    }
                }
                .padding()
                
                Spacer()
                
                // Save button
                Button {
                    Task {
                        await saveProfileStatus()
                    }
                } label: {
                    if isSaving {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Save Changes")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(selectedStatus != userProfile.is_private ? Color.brandOrange : Color.secondary)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding()
                .disabled(selectedStatus == userProfile.is_private || isSaving)
            }
            .navigationTitle("Profile Status")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveProfileStatus() async {
        isSaving = true
        defer { isSaving = false }
        
        do {
            try await SupabaseManager.shared.updateUserProfile(fields: [
                "is_private": AnyEncodable(selectedStatus)
            ])
            
            userProfile.is_private = selectedStatus
            dismiss()
        } catch {
            LOG.error("Failed to update profile status: \(error)")
        }
    }
}
