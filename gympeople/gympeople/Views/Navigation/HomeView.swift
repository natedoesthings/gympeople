//
//  HomeTestView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/6/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var nearbyGymsVM = ListViewModel<Gym>(fetcher: { try await SupabaseManager.shared.fetchMyNearbyGyms() })
    @State private var selectedFilter: UserFilter = .all
    @Binding var tabSelected: Tab
    
    var body: some View {
        ZStack {
            // MARK: - Background Gradient
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.systemGray6)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            NavigationStack {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        headerSection
                        nearbyGymsSection
                        actionButtonsSection
                        peopleNearYouSection
                        
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
        }
        .listErrorAlert(vm: nearbyGymsVM, onRetry: nearbyGymsVM.refresh)
        .task {
            if !nearbyGymsVM.fetched {
               await nearbyGymsVM.load()
            }
        }
    }
}

extension HomeView {

    // MARK: - Header
    private var headerSection: some View {
        HStack(spacing: 16) {
            Image("gympeople_no_bg")
                .resizable()
                .scaledToFit()
                .frame(width: 46, height: 46)

            Text("GymPeople")
                .font(.headline)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .foregroundColor(.primary)
            Spacer()

            headerIcon(
                name: "magnifyingglass",
                destination: SearchView()
            )

            headerIcon(
                name: "bell.fill",
                destination: EmptyView()
            )
            
            Button { tabSelected = .profile } label: {
                AvatarView(url: nil)
                    .frame(width: 36, height: 36)
            }
        }
    }

    private func headerIcon<Destination: View>(
        name: String,
        destination: Destination
    ) -> some View {
        NavigationLink {
            destination
        } label: {
            Image(systemName: name)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
                .padding(10)
                .background(Color(.systemGray5))
                .clipShape(Circle())
        }
    }



    // MARK: - Nearby Gyms
    private var nearbyGymsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nearby Gyms")
                .font(.title3)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundColor(.primary)

            HiddenScrollView(.horizontal) {
                HStack(spacing: 16) {
                    ForEach(nearbyGymsVM.items, id: \.self) { gym in
                        NavigationLink {
                            GymView(gym: gym)
                        } label: {
                            GymCard(gym: gym)
                                .frame(width: 240)
                                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollClipDisabled()
            .ignoresSafeArea(.container, edges: .horizontal)
        }
        .overlay { if nearbyGymsVM.isLoading { ProgressView() } }
    }


    // MARK: - Action Buttons
    private var actionButtonsSection: some View {
        HStack(spacing: 16) {

            actionTile(
                title: "Look for a Gym Buddy",
                icon: "person.2.fill"
            ) { }

            actionTile(
                title: "Create a Gym Group",
                icon: "plus.circle.fill"
            ) { }
        }
    }

    private func actionTile(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
            .background(Color.brandOrange)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color.brandOrange.opacity(0.3), radius: 6, x: 0, y: 4)
        }
    }

    private var filterBar: some View {
        HiddenScrollView(.horizontal) {
            HStack(spacing: 12) {
                ForEach(UserFilter.allCases) { filter in
                    Button {
                        selectedFilter = filter
                    } label: {
                        Text(filter.rawValue)
                            .font(.callout)
                            .fontWeight(.medium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                selectedFilter == filter
                                ? Color.brandOrange.opacity(0.9)
                                : Color(.systemGray6)
                            )
                            .foregroundColor(selectedFilter == filter ? .white : .primary)
                            .clipShape(Capsule())
                            .animation(.spring(duration: 0.25), value: selectedFilter)
                    }
                }
            }
            .padding(.horizontal)
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollClipDisabled()
    }
    

    // MARK: - People Near You
    private var peopleNearYouSection: some View {
        VStack(alignment: .leading, spacing: 16) {

            Text("People Near You")
                .font(.title3)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundColor(.primary)

            filterBar
            
            
            VStack(spacing: 14) {
                ForEach(0..<6, id: \.self) { _ in
                    UserRow(profile: .placeholder())
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(Color.standardPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 3)
                }
            }
        }
        .padding(.bottom, 40)
    }
    
    

}
