//
//  ReceiveMessagePayload.swift
//  We&Movie
//

import Foundation

/// Incoming message from WatchHub ReceiveMessage event
struct ReceiveMessagePayload: Codable, Sendable {
    let messageId: Int
    let userId: Int
    let nickname: String
    let text: String
    let sentAt: String
    let isReadByCurrentUser: Bool
}
