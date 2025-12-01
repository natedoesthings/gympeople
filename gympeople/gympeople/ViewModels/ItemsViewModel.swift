//
//  ItemsViewModel.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/1/25.
//

import Foundation
import Combine

@MainActor
final class ListViewModel<Item>: ObservableObject {
    @Published var items: [Item] = []
    @Published var currentError: AppError?
    @Published var isLoading = false

    private let fetcher: () async throws -> [Item]

    init(fetcher: @escaping () async throws -> [Item]) {
        self.fetcher = fetcher
    }

    func load() {
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                items = try await fetcher()
            } catch let err as AppError {
                currentError = err
            } catch {
                currentError = .unexpected
            }
        }
    }

    func refresh() {
        load() // or add custom logic before/after
    }
}
