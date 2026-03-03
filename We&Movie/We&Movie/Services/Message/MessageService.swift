//
//  MessageService.swift
//  We&Movie
//

import Foundation

/// Message service: list, read, delete.
final class MessageService: Sendable {

    static let shared = MessageService()
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    /// Get messages for room. lastMessageId for pagination (older messages).
    func getMessages(roomId: Int, lastMessageId: Int? = nil) async throws -> [Message] {
        var path = "api/Message/chats/\(roomId)/messages"
        if let id = lastMessageId {
            path += "?lastMessageId=\(id)"
        }
        let data = try await client.get(path: path)
        return try client.decode([Message].self, from: data)
    }

    /// Mark message as read.
    func markAsRead(messageId: Int) async throws {
        _ = try await client.put(path: "api/Message/messages/\(messageId)/read")
    }

    /// Mark all messages in room as read.
    func markAllAsRead(roomId: Int) async throws {
        _ = try await client.put(path: "api/Message/chats/\(roomId)/read-all")
    }

    /// Delete message. forAll: true — for everyone (admin only), false — only for self.
    func deleteMessage(messageId: Int, forAll: Bool = false) async throws {
        let path = "api/Message/messages/\(messageId)?forAll=\(forAll)"
        _ = try await client.delete(path: path)
    }
}
