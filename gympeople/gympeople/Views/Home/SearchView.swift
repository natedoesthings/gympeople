//
//  SearchView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/23/25.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var searchText: String = ""

    var body: some View {
        VStack(spacing: 16) {
            searchField

            Group {
                if viewModel.isSearching {
                    ProgressView("Searching...")
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else if viewModel.results.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(viewModel.results) { profile in
                                userRow(profile)
                                Divider()
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Search")
        .onChange(of: searchText) { newValue in
            viewModel.search(query: newValue)
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search by username", text: $searchText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }

    private var emptyState: some View {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return VStack(alignment: .leading, spacing: 6) {
            Text(trimmed.isEmpty ? "Find people to follow" : "No users found")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(trimmed.isEmpty ? "Type a username to start searching." : "Try a different username.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func userRow(_ profile: UserProfile) -> some View {
        NavigationStack {
            HStack(spacing: 12) {
                NavigationLink {
                    UserProfileView(userProfile: profile)
                } label: {
                    AvatarView(url: profile.pfp_url)
                        .frame(width: 48, height: 48)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("@\(profile.user_name)")
                            .font(.headline)
                            .foregroundStyle(.invertedPrimary)
                        
                        Text("\(profile.first_name) \(profile.last_name)")
                            .font(.subheadline)
                            .foregroundStyle(Color(.systemGray))
                    }
                    
                    
                    Spacer()
                }
            }
            .padding(.vertical, 4)
        }
    }
}
