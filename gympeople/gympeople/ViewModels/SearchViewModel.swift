//
//  SearchViewModel.swift
//  gympeople
//
//  Created by Codex on 12/26/24.
//

import Combine
import Foundation

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var results: [UserProfile] = []
    @Published var isSearching: Bool = false
    @Published var errorMessage: String?

    private let manager = SupabaseManager.shared
    private var searchTask: Task<Void, Never>?
    private let minQueryLength = 3
    private let debounceDelay: UInt64 = 400_000_000 // 400ms in nanoseconds

    func search(query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)

        // Cancel any in-flight search and clear results if the query is empty.
        searchTask?.cancel()
        guard trimmed.count >= minQueryLength else {
            results = []
            errorMessage = nil
            return
        }

        searchTask = Task { [weak self] in
            // Small debounce to avoid hammering the backend while the user is typing quickly.
            try? await Task.sleep(nanoseconds: debounceDelay)
            guard let self else { return }
            guard !Task.isCancelled else { return }

            do {
                isSearching = true
                defer { isSearching = false }

                let profiles = try await manager.searchUserProfiles(matching: trimmed, limit: 20)
                guard !Task.isCancelled else { return }

                results = profiles
                errorMessage = nil
            } catch {
                guard !Task.isCancelled else { return }
                LOG.error("Search failed: \(error)")
                results = []
                errorMessage = "Couldn't load users right now."
            }
        }
    }
}
