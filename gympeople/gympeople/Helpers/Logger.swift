//
//  Logger.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/16/25.
//

import os
import Foundation

/// Centralized logging utility for the app.
enum LOG {

    static func info(_ message: String) {
        Logger().info("[INFO] \(message, privacy: .public)")
    }

    static func debug(_ message: String) {
        #if DEBUG
        Logger().debug("[DEBUG] \(message, privacy: .public)")
        #endif
    }

    static func notice(_ message: String) {
        Logger().notice("[NOTICE] \(message, privacy: .public)")
    }

    static func warning(_ message: String) {
        Logger().warning("[WARNING] \(message, privacy: .public)")
    }

    static func error(_ message: String) {
        Logger().error("[ERROR] \(message, privacy: .public)")
    }

    static func fault(_ message: String) {
        Logger().fault("[FAULT] \(message, privacy: .public)")
    }
}
