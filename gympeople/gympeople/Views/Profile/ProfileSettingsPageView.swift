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
    
    @ObservedObject var gymsVM: ListViewModel<Gym>
    
    @State private var showLogoutAlert: Bool = false
    @State private var showProfileStatusSheet: Bool = false
    @State private var showMembershipsSheet: Bool = false
    
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
                                iconColor: .orange,
                                value: userProfile.is_private ? "Private" : "Public",
                                action: { showProfileStatusSheet = true }
                            )
                            
                        }
                    }
                    
                    // Memberships Section
                    VStack(spacing: 0) {
                        header("Gym Memberships")
                        
                        if gymsVM.items.isEmpty {
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
                                        iconColor: .orange,
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
                        Image(systemName: gym.verification_status!.icon)
                            .font(.system(size: 10))
                        Text(gym.verification_status!.name)
                            .font(.system(size: 11))
                    }
                    .foregroundStyle(gym.verification_status!.color)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(gym.verification_status!.color.opacity(0.15))
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





