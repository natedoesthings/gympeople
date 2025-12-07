//
//  ProfileSettingsPageView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/19/25.
//

import SwiftUI

struct ProfileSettingsPageView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State var userProfile: UserProfile
    
    @StateObject private var gymsVM: ListViewModel<Gym>
    
    @State private var showLogoutAlert: Bool = false
    @State private var showProfileStatusSheet: Bool = false
    @State private var showMembershipsSheet: Bool = false
    
    init(userProfile: UserProfile) {
        _userProfile = State(initialValue: userProfile)
        _gymsVM = StateObject(wrappedValue: ListViewModel<Gym> {
            try await SupabaseManager.shared.fetchMyGymMemberships()
        })
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with profile info
            profileHeader
            
            Divider()
            
            // Settings content
            HiddenScrollView {
                VStack(spacing: 24) {
                    // Profile Section
                    VStack(spacing: 0) {
                        header("Profile")
                        
                        VStack(spacing: 0) {
                            settingsRow(
                                title: "Profile Status",
                                icon: "eye",
                                iconColor: .purple,
                                value: userProfile.is_private ? "Private" : "Public",
                                action: { showProfileStatusSheet = true }
                            )
                            
                        }
                    }
                    
                    // Memberships Section
                    VStack(spacing: 0) {
                        header("Gym Memberships")
                        
                        if gymsVM.isLoading {
                            HStack {
                                ProgressView()
                                    .padding()
                                Spacer()
                            }
                        } else if gymsVM.items.isEmpty {
                            settingsRow(
                                title: "No Memberships",
                                icon: "dumbbell",
                                iconColor: .orange,
                                value: "Add gyms",
                                action: { showMembershipsSheet = true }
                            )
                        } else {
                            VStack(spacing: 0) {
                                ForEach(Array(gymsVM.items.prefix(3).enumerated()), id: \.element) { index, gym in
                                    membershipRow(gym: gym)
                                    
                                    if index < min(2, gymsVM.items.count - 1) {
                                        Divider()
                                            .padding(.leading, 56)
                                    }
                                }
                                
                                if gymsVM.items.count > 3 {
                                    Divider()
                                        .padding(.leading, 56)
                                    
                                    Button {
                                        showMembershipsSheet = true
                                    } label: {
                                        HStack {
                                            Spacer()
                                                .frame(width: 56)
                                            
                                            Text("View all \(gymsVM.items.count) memberships")
                                                .font(.subheadline)
                                                .foregroundStyle(.brandOrange)
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        .padding(.vertical, 12)
                                    }
                                } else {
                                    Divider()
                                        .padding(.leading, 56)
                                    
                                    settingsRow(
                                        title: "Manage Memberships",
                                        icon: "pencil",
                                        iconColor: .blue,
                                        value: "",
                                        showChevron: true,
                                        action: { showMembershipsSheet = true }
                                    )
                                }
                            }
                        }
                    }
                    
                    // App Settings Section (placeholder for future)
                    VStack(spacing: 0) {
                        header("App")
                        
                        VStack(spacing: 0) {
                            settingsRow(
                                title: "Notifications",
                                icon: "bell",
                                iconColor: .blue,
                                value: "Coming soon",
                                isDisabled: true
                            )
                            
                            Divider()
                                .padding(.leading, 56)
                            
                            settingsRow(
                                title: "Privacy & Security",
                                icon: "lock",
                                iconColor: .green,
                                value: "Coming soon",
                                isDisabled: true
                            )
                        }
                    }
                    
                    // Logout button
                    Button {
                        showLogoutAlert = true
                    } label: {
                        Text("Logout")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.error)
                            .cornerRadius(12)
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 120) // Extra padding for tab bar
                }
                .padding(.horizontal)
            }
        }
        .task {
            if !gymsVM.fetched {
                await gymsVM.load()
            }
        }
        .sheet(isPresented: $showProfileStatusSheet) {
            ProfileStatusSheet(userProfile: $userProfile)
        }
        .sheet(isPresented: $showMembershipsSheet) {
            MembershipsSheet(gymsVM: gymsVM)
        }
        .alert(isPresented: $showLogoutAlert) {
            Alert(
                title: Text("Log out of @\(userProfile.user_name)?"),
                message: Text("Any ongoing activity will stop and your profile will no longer be active on this device."),
                primaryButton: .cancel(Text("Cancel")),
                secondaryButton: .destructive(Text("Logout"), action: {
                    Task {
                        await authVM.signOut()
                    }
                })
            )
        }
    }
    
    // MARK: - Components
    
    private var profileHeader: some View {
        VStack(spacing: 12) {
            AvatarView(url: userProfile.pfp_url)
                .frame(width: 80, height: 80)
            
            VStack(spacing: 4) {
                Text("\(userProfile.first_name) \(userProfile.last_name)")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("@\(userProfile.user_name)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 16)
    }
    
    @ViewBuilder
    private func header(_ content: String) -> some View {
        Text(content)
            .font(.system(size: 13))
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private func settingsRow(
        title: String,
        icon: String,
        iconColor: Color,
        value: String,
        showChevron: Bool = true,
        isDisabled: Bool = false,
        action: (() -> Void)? = nil
    ) -> some View {
        Button {
            if !isDisabled {
                action?()
            }
        } label: {
            HStack(spacing: 12) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(isDisabled ? .secondary : iconColor)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(isDisabled ? Color(.systemGray6) : iconColor.opacity(0.15))
                    )
                
                // Title
                Text(title)
                    .font(.body)
                    .foregroundStyle(isDisabled ? .secondary : .primary)
                
                Spacer()
                
                // Value
                if !value.isEmpty {
                    Text(value)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                // Chevron
                if showChevron && !isDisabled {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 12)
        }
        .disabled(isDisabled)
    }
    
    @ViewBuilder
    private func membershipRow(gym: Gym) -> some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 16))
                .foregroundStyle(.brandOrange)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color.brandOrange.opacity(0.15))
                )
            
            // Gym info
            VStack(alignment: .leading, spacing: 2) {
                Text(gym.name ?? "Unknown Gym")
                    .font(.body)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    // Verification status badge
                    HStack(spacing: 4) {
                        Image(systemName: "hourglass")
                            .font(.system(size: 10))
                        Text("Pending")
                            .font(.system(size: 11))
                    }
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color.orange.opacity(0.15))
                    )
                    
                    if let address = gym.address?.components(separatedBy: ",").first {
                        Text("•")
                            .foregroundStyle(.secondary)
                            .font(.caption2)
                        
                        Text(address)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
    }
}

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

// MARK: - Memberships Sheet

struct MembershipsSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var gymsVM: ListViewModel<Gym>
    
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
                            membershipDetailRow(gym: gym)
                            
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
            .overlay {
                if gymsVM.isLoading {
                    ProgressView()
                }
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
                        Image(systemName: "hourglass")
                            .font(.system(size: 12))
                        Text("Pending Verification")
                            .font(.system(size: 13))
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.orange.opacity(0.15))
                    )
                }
                .padding(.top, 4)
                
                // Info text
                Text("We're reviewing your membership. This usually takes 1-2 business days.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
    }
}

#Preview {
    ProfileSettingsPageView(userProfile: .placeholder())
        .environmentObject(AuthViewModel())
}
