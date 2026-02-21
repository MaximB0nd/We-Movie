//
//  Chat.swift
//  We&Movie
//

import Foundation

/// Chat list item: GET /api/chat/chats
struct Chat: Codable, Sendable {
    let id: Int
    let isGroup: Bool
    let name: String?           // for group chat
    let lastMessagePreview: String?
    let lastMessageTime: String? // ISO8601, e.g. "2026-01-31T18:00:00Z"
    let unreadCount: Int
    let members: [ChatMember]
}
