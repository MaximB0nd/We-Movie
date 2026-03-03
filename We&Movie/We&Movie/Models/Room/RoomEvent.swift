//
//  RoomEvent.swift
//  We&Movie
//

import Foundation

/// Room event from WatchHub: MemberJoined, MemberLeft (RoomEventDTO)
/// eventType: "joined", "left", "role_changed"
struct RoomEvent: Codable, Sendable {
    let eventType: String
    let userId: Int
    let nickname: String
    let newRole: String?
}
