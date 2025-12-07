//
//  UserFilter.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/5/25.
//


enum UserFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case weightlifter = "Weightlifter"
    case climber = "Climber"
    case runner = "Runner"
    case gymnast = "Gymnast"

    var id: String { rawValue }
}
