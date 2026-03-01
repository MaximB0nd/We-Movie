//
//  ChatMember.swift
//  We&Movie
//

import Foundation

/// Chat member in list
struct ChatMember: Codable, Sendable {
    let id: Int
    let nickname: String
}
