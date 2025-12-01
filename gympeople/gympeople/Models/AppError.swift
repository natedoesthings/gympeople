//
//  AppError.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/1/25.
//

enum AppError: Error {
    case networkUnavailable
    case unauthorized
    case validationFailed(reason: String?)
    case conflict
    case notFound
    case serverError
    case unexpected
}

struct ErrorPresenter {
    static func message(for error: AppError) -> (title: String, detail: String, action: String?) {
        switch error {
        case .networkUnavailable:
            return ("No connection", "Check your internet and try again.", "Retry")
        case .unauthorized:
            return ("Signed out", "Please sign in to continue.", "Sign in")
        case .validationFailed(let reason):
            return ("Check input", reason ?? "Some fields need attention.", nil)
        case .conflict:
            return ("Already exists", "That item already exists. Try a different value.", nil)
        case .notFound:
            return ("Not found", "We couldn’t find that item.", nil)
        case .serverError:
            return ("Server issue", "We’re having trouble right now. Try again soon.", "Retry")
        case .unexpected:
            return ("Something went wrong", "Please try again.", "Retry")
        }
    }
}
