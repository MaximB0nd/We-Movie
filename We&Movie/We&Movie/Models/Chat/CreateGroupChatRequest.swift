//
//  CreateGroupChatRequest.swift
//  We&Movie
//

import Foundation

/// Create group chat request: POST /api/chat/group
struct CreateGroupChatRequest: Codable, Sendable {
    let name: String
    let initialMemberIds: [Int]  // without creator
}
