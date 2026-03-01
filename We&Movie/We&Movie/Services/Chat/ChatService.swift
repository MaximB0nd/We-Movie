//
//  ChatService.swift
//  We&Movie
//

import Foundation

/// Chat service: list, create private/group, delete, add/remove members.
/// All requests go with Bearer token via APIClient.
final class ChatService: Sendable {

    static let shared = ChatService()
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    // MARK: - Chats list

    /// Get all chats for current user. Sorted by LastActivityAt DESC.
    func getChats() async throws -> [Chat] {
        let data = try await client.get(path: "api/chat/chats")
        return try client.decode([Chat].self, from: data)
    }

    // MARK: - Create private chat

    /// Create private 1:1 chat. If chat exists — returns its ID.
    /// - Returns: ID of new or existing chat
    func createPrivateChat(otherUserId: Int) async throws -> Int {
        let body = CreatePrivateChatRequest(otherUserId: otherUserId)
        let data = try await client.post(path: "api/chat/private", body: body)
        return try decodeInt(from: data)
    }

    // MARK: - Create group chat

    /// Create group chat. Creator is added as admin automatically.
    /// - Returns: ID of new chat
    func createGroupChat(name: String, initialMemberIds: [Int]) async throws -> Int {
        let body = CreateGroupChatRequest(name: name, initialMemberIds: initialMemberIds)
        let data = try await client.post(path: "api/chat/group", body: body)
        return try decodeInt(from: data)
    }

    // MARK: - Delete chat

    /// Delete chat. Only admin can delete.
    func deleteChat(chatId: Int) async throws {
        _ = try await client.delete(path: "api/chat/\(chatId)")
    }

    // MARK: - Add member (group)

    /// Add member to group chat. Admin only.
    func addMember(chatId: Int, userId: Int) async throws {
        let body = AddRemoveMemberRequest(userId: userId)
        _ = try await client.put(path: "api/chat/\(chatId)/add-member", body: body)
    }

    // MARK: - Remove member (group)

    /// Remove member from group chat. Admin only.
    func removeMember(chatId: Int, userId: Int) async throws {
        let body = AddRemoveMemberRequest(userId: userId)
        _ = try await client.put(path: "api/chat/\(chatId)/remove-member", body: body)
    }

    // MARK: - Helpers

    private func decodeInt(from data: Data) throws -> Int {
        // Server returns plain number: 1 or 3
        if let int = try? JSONDecoder().decode(Int.self, from: data) {
            return int
        }
        if let double = try? JSONDecoder().decode(Double.self, from: data) {
            return Int(double)
        }
        throw APIError.decoding(NSError(domain: "ChatService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ожидалось число"]))
    }
}
