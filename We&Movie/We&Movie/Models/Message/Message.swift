//
//  Message.swift
//  We&Movie
//

import Foundation

/// Message: GET /api/Message/chats/{roomId}/messages
struct Message: Codable, Sendable {
    let messageId: Int
    let senderId: Int
    let senderNickname: String
    let roomId: Int
    let text: String
    let sentAt: String  // ISO8601
    let deliveredAt: String?
    let isReadByCurrentUser: Bool

    enum CodingKeys: String, CodingKey {
        case messageId, senderId, senderNickname, text, sentAt, deliveredAt, isReadByCurrentUser
        case roomId = "chatId"
    }
}
