//
//  Room.swift
//  We&Movie
//

import Foundation

/// Room list item: GET /api/Chat/chats (ChatPreviewDto)
struct Room: Codable, Sendable {
    let id: Int
    let name: String
    let lastMessagePreview: String?
    let lastMessageTime: String? // ISO8601, e.g. "2025-03-01T20:00:00Z"
    let unreadCount: Int
    let members: [RoomMember]
}
