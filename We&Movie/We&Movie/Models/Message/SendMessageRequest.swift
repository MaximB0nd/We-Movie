//
//  SendMessageRequest.swift
//  We&Movie
//

import Foundation

/// Request for SendRoomMessage (WatchHub, API: SendChatMessage)
struct SendMessageRequest: Codable, Sendable {
    let roomId: Int64
    let text: String
}
