//
//  ChatMember.swift
//  We&Movie
//

import Foundation

/// Участник чата в списке
struct ChatMember: Codable, Sendable {
    let id: Int
    let nickname: String
}
