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
            return "< 0.1 mi away"
        } else {
            return String(format: "%.1f mi away", miles)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Gym Name + Distance
            HStack {
                Text(gym.name ?? "Unknown Gym")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if let distance = formattedDistance {
                    Text(distance)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
            }

            // Address
            if let address = gym.address {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.blue)
                        .font(.subheadline)

                    Text(address)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
            }
            
            // Phone Number
            if let phone = gym.phone_number {
                HStack(spacing: 8) {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.green)
                        .font(.subheadline)

                    Text(phone)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            // Website
            if let urlString = gym.url,
               let websiteURL = URL(string: urlString) {

                HStack(spacing: 8) {
                    Image(systemName: "globe")
                        .foregroundColor(.orange)
                        .font(.subheadline)

                    Link(destination: websiteURL) {
                        Text(urlString)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .lineLimit(1)
                            .underline() // Optional: makes it clear it's clickable
                    }
                }
            }

            Divider()

            // Stats Row
            HStack(spacing: 20) {
                HStack(spacing: 6) {
                    Image(systemName: "person.3.fill")
                        .foregroundColor(.purple)
                    Text("\(gym.member_count) members")
                }
                .font(.footnote)

                HStack(spacing: 6) {
                    Image(systemName: "text.bubble.fill")
                        .foregroundColor(.pink)
                    Text("\(gym.post_count) posts")
                }
                .font(.footnote)
            }
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 4)
    }
}


#Preview {
    GymCard(gym: GYMS[0])
}
