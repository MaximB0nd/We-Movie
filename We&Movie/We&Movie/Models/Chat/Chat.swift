//
//  Chat.swift
//  We&Movie
//

import Foundation

/// Элемент списка чатов: GET /api/chat/chats
struct Chat: Codable, Sendable {
    let id: Int
    let isGroup: Bool
    let name: String?           // для группового чата
    let lastMessagePreview: String?
    let lastMessageTime: String? // ISO8601, напр. "2026-01-31T18:00:00Z"
    let unreadCount: Int
    let members: [ChatMember]
}
