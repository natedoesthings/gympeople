//
//  TimeAgo.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/3/25.
//

import Foundation

func timeAgo(_ date: Date) -> String {
    let interval = Date().timeIntervalSince(date)
    
    let minutes = Int(interval / 60)
    let hours = Int(interval / 3600)
    let days = Int(interval / 86400)
    
    if minutes < 1 { return "now" }
    if minutes < 60 { return "\(minutes)m" }
    if hours < 24 { return "\(hours)h" }
    return "\(days)d"
}
