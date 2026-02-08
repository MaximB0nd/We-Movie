//
//  CreateGroupChatRequest.swift
//  We&Movie
//

import Foundation

/// Запрос создания группового чата: POST /api/chat/group
struct CreateGroupChatRequest: Codable, Sendable {
    let name: String
    let initialMemberIds: [Int]  // без создателя
}
