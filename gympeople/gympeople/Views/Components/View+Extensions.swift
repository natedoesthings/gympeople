//
//  View+Extensions.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/3/25.
//
import SwiftUI

extension View {
    func listErrorAlert<Item>(
        vm: ListViewModel<Item>,
        onRetry: @escaping () async -> Void
    ) -> some View {
        alert(isPresented: Binding(
            get: { vm.currentError != nil },
            set: { _ in vm.currentError = nil }
        )) {
            let info = ErrorPresenter.message(for: vm.currentError ?? .unexpected)
            return Alert(
                title: Text(info.title),
                message: Text(info.detail),
                dismissButton: .default(Text(info.action ?? "OK")) {
                    if info.action != nil { Task { await onRetry() } }
                }
            )
        }
    }
}
