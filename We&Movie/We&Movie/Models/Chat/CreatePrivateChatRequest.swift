//
//  CreatePrivateChatRequest.swift
//  We&Movie
//

import Foundation

/// Create private chat request: POST /api/chat/private
struct CreatePrivateChatRequest: Codable, Sendable {
    let otherUserId: Int
}
