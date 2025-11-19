//
//  LoginError.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/12/25.
//

import Foundation
import Supabase

enum LoginError: Error, Identifiable {
    var id: String { localizedDescription } // allows use in .alert(item:)

    case missingEmailOrPhone
    case invalidCredentials
    case weakPassword
    case unknown(message: String)

    var message: String {
        switch self {
        case .missingEmailOrPhone:
            return "Please enter your email and password before signing in."
        case .invalidCredentials:
            return "The email or password you entered is incorrect. Try again."
        case .weakPassword:
            return "Your password is too weak: It must be at least 8 characters and contain at least one uppercase letter, one lowercase letter, and one digit and one special character."
        case .unknown(let message):
            return "An unexpected error occurred: \(message)"
        }
    }

    // MARK: - Factory initializer from Supabase error
    static func from(_ error: Error) -> LoginError {
        // Handle Supabase AuthError
        if let supabaseError = error as? AuthError {
            switch supabaseError {
            case .api(let message, let errorCode, _, _):
                switch errorCode.rawValue {
                case "validation_failed":
                    return .missingEmailOrPhone
                case "invalid_credentials":
                    return .invalidCredentials
                default:
                    return .unknown(message: message)
                }

            case .weakPassword:
                return .weakPassword
            default:
                return .unknown(message: supabaseError.localizedDescription)
            }
        }

        // Handle any other non-Supabase error types
        return .unknown(message: error.localizedDescription)
    }
}
