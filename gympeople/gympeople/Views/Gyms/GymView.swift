//
//  GymView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/28/25.
//

import SwiftUI
import MapKit

struct GymSuggestionView: View {
    let suggestion: MKLocalSearchCompletion
    
    @State private var gym: Gym?
    @State private var poiError: MKPOIError?
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            if let gym = gym {
                GymView(gym: gym)
            } else {
                ProgressView()
            }
        }
        .task {
            await loadGym()
        }
        .alert(item: $poiError) { error in
            Alert(
                title: Text("Invalid Location"),
                message: Text(error.localizedDescription),
                dismissButton: .default(Text("OK")) {
                    dismiss()  // go back to previous view
                }
            )
        }
    }
    
    // Separate loader for clarity
    private func loadGym() async {
        do {
            if let gym = try await selectSuggestion(suggestion) {
                self.gym = gym
            } else {
                // No result -> treat as invalid selection
                self.poiError = .incorrectCategory
            }
        } catch let error as MKPOIError {
            self.poiError = error
        } catch {
            print("Unexpected error:", error)
            self.poiError = .incorrectCategory
        }
    }
    
    func selectSuggestion(_ suggestion: MKLocalSearchCompletion) async throws -> Gym? {
        let request = MKLocalSearch.Request(completion: suggestion)
        let search = MKLocalSearch(request: request)
        
        let response = try await search.start()
        
        guard let first = response.mapItems.first else {
            return nil
        }
        
        // Require fitness center category
        if let category = first.pointOfInterestCategory,
           category != .fitnessCenter {
            throw MKPOIError.incorrectCategory
        }
        
        // If there's no category at all, you may also want to treat it as invalid:
        if first.pointOfInterestCategory == nil {
            throw MKPOIError.incorrectCategory
        }
        
        return Gym.from(mapItem: first)
    }
}


struct GymView: View {
    @Environment(\.openURL) var openURL
    let gym: Gym
    @State private var posts: [NearbyPost]?
    @State private var showPostView: Bool = false
    
    var formattedDistance: String? {
        guard let meters = gym.distance_meters else { return nil }
        let miles = meters / 1609.34
        return String(format: "%.1f mi away", miles)
    }
    
    var body: some View {
        HiddenScrollView {
            VStack(spacing: 24) {
                
                // Top card with gym summary
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(gym.name ?? "Unknown Gym")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            if let distance = formattedDistance {
                                HStack(spacing: 6) {
                                    Image(systemName: "location")
                                        .font(.caption)
                                    Text(distance)
                                }
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            }
                        }
                        
                        Spacer()
                    }
                    
                    // Address Row (Tappable)
                    if let address = gym.address {
                        Button {
                            openInMaps(
                                lat: gym.latitude,
                                lon: gym.longitude,
                                name: gym.name
                            )
                        } label: {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundStyle(.brandOrange)
                                    .font(.subheadline)

                                Text(address)
                                    .font(.subheadline)
                                    .foregroundStyle(.blue)
                                    .underline()
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        .buttonStyle(.plain)
                    }

                    // Phone Row (Tappable)
                    if let phone = gym.phone_number {
                        Button {
                            callNumber(phone)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "phone.fill")
                                    .foregroundStyle(.green)
                                    .font(.subheadline)
                                Text(phone)
                                    .font(.subheadline)
                                    .foregroundStyle(.blue)
                                    .underline()
                            }
                        }
                        .buttonStyle(.plain)
                    }

                    
                    if let urlString = gym.url,
                       let websiteURL = URL(string: urlString) {
                        HStack(spacing: 8) {
                            Image(systemName: "globe")
                                .foregroundStyle(.blue)
                                .font(.subheadline)
                            
                            Link(destination: websiteURL) {
                                Text("Visit website")
                                    .font(.subheadline)
                                    .foregroundStyle(.blue)
                                    .underline()
                            }
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                
                // Stats row
                HStack(spacing: 16) {
                    statCard(
                        icon: "person.3.fill",
                        title: "Members",
                        value: "\(gym.member_count)"
                    )
                    
                    statCard(
                        icon: "text.bubble.fill",
                        title: "Posts",
                        value: "\(gym.post_count)"
                    )
                }
                
                // Create post CTA
                VStack(alignment: .leading, spacing: 8) {
                    Text("Share something at this gym")
                        .font(.headline)
                    
                    Button {
                        showPostView = true
                    } label: {
                        HStack {
                            Image(systemName: "square.and.pencil")
                            Text("Create a post at \(gym.name ?? "this gym")")
                                .lineLimit(1)
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.brandOrange)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .shadow(radius: 4, y: 2)
                    }
                }
                
                // Placeholder for future gym feed
                LazyVStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Recent posts")
                            .font(.headline)
                        Spacer()
                    }
                    
                    if let posts = posts, !posts.isEmpty {
                        ForEach(posts) { post in
                            PostCard(
                                    post: Post(
                                        id: post.post_id,
                                        user_id: post.post_user_id,
                                        content: post.content,
                                        created_at: post.created_at,
                                        updated_at: post.updated_at,
                                        like_count: post.like_count,
                                        comment_count: post.comment_count,
                                        is_liked: post.is_liked,
                                        gym_id: post.gym_id
                                    ),
                                    displayName: post.author_first_name + post.author_last_name,
                                    username: post.author_user_name,
                                    avatarURL: post.author_pfp_url,
                                    feed: true
                                )
                                .padding()
                                .padding(.vertical, -10)
                            
                            Divider()
                        }
                    } else {
                        Text("Posts from this gym will show up here.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
            }
            .padding()
        }
        .navigationTitle(gym.name ?? "Gym")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPostView) {
            PostView(gymTag: gym.id)
        }
        .onAppear {
            Task {
                posts = await SupabaseManager.shared.fetchGymPosts(for: gym.id)
            }
        }
    }
    
    // MARK: - Components
    
    @ViewBuilder
    private func statCard(icon: String, title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.subheadline)
                Text(title)
                    .font(.subheadline)
            }
            .foregroundStyle(.secondary)
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 5, x: 0, y: 3)
    }
    
    private func openInMaps(lat: Double, lon: Double, name: String?) {
        let location = CLLocation(latitude: lat, longitude: lon)
        let mapItem = MKMapItem(location: location, address: nil)
        mapItem.name = name
        mapItem.openInMaps()
    }

    private func callNumber(_ number: String) {
        let cleaned = number.replacingOccurrences(of: " ", with: "")
        if let url = URL(string: "tel://\(cleaned)") {
            openURL(url)
        }
    }

}
