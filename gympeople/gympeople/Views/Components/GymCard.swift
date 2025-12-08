//
//  GymCard.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/30/25.
//

import SwiftUI

struct GymCard: View {
    let gym: Gym
    
    // Format distance for display
    var formattedDistance: String? {
        guard let meters = gym.distance_meters else { return nil }
        
        let miles = meters / 1609.34
        
        if miles < 0.1 {
            return "< 0.1 mi"
        } else {
            return String(format: "%.1f mi", miles)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header Section - Gym Name + Icon
            HStack(spacing: 12) {
                // Gym Icon
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        LinearGradient(
                            colors: [Color("BrandOrange"), Color("BrandOrange").opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(gym.name ?? "Unknown Gym")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    if let distance = formattedDistance {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.caption)
                            Text(distance)
                                .font(.subheadline)
                        }
                        .foregroundStyle(Color("BrandOrange"))
                    }
                }
                
                Spacer()
            }
            .padding(16)
            
            // Divider
            Divider()
                .padding(.horizontal, 16)
            
            // Contact Info Section
            VStack(alignment: .leading, spacing: 12) {
                // Address
                if let address = gym.address {
                    InfoRow(
                        icon: "mappin.circle.fill",
                        iconColor: Color("BrandOrange"),
                        text: address
                    )
                }
                
                // Phone Number
                if let phone = gym.phone_number {
                    InfoRow(
                        icon: "phone.circle.fill",
                        iconColor: .green,
                        text: phone
                    )
                }
                
                // Website
                if let urlString = gym.url,
                   let websiteURL = URL(string: urlString) {
                    HStack(spacing: 10) {
                        Image(systemName: "link.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(.blue)
                        
                        Link(destination: websiteURL) {
                            Text("Visit Website")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .underline()
                        }
                    }
                }
            }
            .padding(16)
            
            // Stats Section
            HStack(spacing: 0) {
                StatBadge(
                    icon: "person.3.fill",
                    value: "\(gym.member_count)",
                    label: "members"
                )
                
                Divider()
                    .frame(height: 40)
                
                StatBadge(
                    icon: "text.bubble.fill",
                    value: "\(gym.post_count)",
                    label: "posts"
                )
            }
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6).opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Supporting Views

struct InfoRow: View {
    let icon: String
    let iconColor: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(iconColor)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
    }
}

struct StatBadge: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Color("BrandOrange"))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}

#Preview {
    GymCard(gym: GYMS[0])
        .padding()
}
