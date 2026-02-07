//
//  CreatePrivateChatRequest.swift
//  We&Movie
//

import Foundation

/// Запрос создания приватного чата: POST /api/chat/private
struct CreatePrivateChatRequest: Codable, Sendable {
    let otherUserId: Int
}
