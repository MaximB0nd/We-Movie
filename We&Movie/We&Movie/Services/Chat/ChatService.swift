//
//  ChatService.swift
//  We&Movie
//

import Foundation

/// Сервис чатов: список, создание приватного/группового, удаление, добавление/удаление участников.
/// Все запросы идут с Bearer-токеном через APIClient.
final class ChatService: Sendable {

    static let shared = ChatService()
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    // MARK: - Chats list

    /// Получить все чаты текущего пользователя. Сортировка по LastActivityAt DESC.
    func getChats() async throws -> [Chat] {
        let data = try await client.get(path: "api/chat/chats")
        return try client.decode([Chat].self, from: data)
    }

    // MARK: - Create private chat

    /// Создать приватный чат 1:1. Если чат уже есть — вернётся его ID.
    /// - Returns: ID нового или существующего чата
    func createPrivateChat(otherUserId: Int) async throws -> Int {
        let body = CreatePrivateChatRequest(otherUserId: otherUserId)
        let data = try await client.post(path: "api/chat/private", body: body)
        return try decodeInt(from: data)
    }

    // MARK: - Create group chat

    /// Создать групповой чат. Создатель добавляется как админ автоматически.
    /// - Returns: ID нового чата
    func createGroupChat(name: String, initialMemberIds: [Int]) async throws -> Int {
        let body = CreateGroupChatRequest(name: name, initialMemberIds: initialMemberIds)
        let data = try await client.post(path: "api/chat/group", body: body)
        return try decodeInt(from: data)
    }

    // MARK: - Delete chat

    /// Удалить чат. Только админ может удалить.
    func deleteChat(chatId: Int) async throws {
        _ = try await client.delete(path: "api/chat/\(chatId)")
    }

    // MARK: - Add member (group)

    /// Добавить участника в групповой чат. Только админ.
    func addMember(chatId: Int, userId: Int) async throws {
        let body = AddRemoveMemberRequest(userId: userId)
        _ = try await client.put(path: "api/chat/\(chatId)/add-member", body: body)
    }

    // MARK: - Remove member (group)

    /// Удалить участника из группового чата. Только админ.
    func removeMember(chatId: Int, userId: Int) async throws {
        let body = AddRemoveMemberRequest(userId: userId)
        _ = try await client.put(path: "api/chat/\(chatId)/remove-member", body: body)
    }

    // MARK: - Helpers

    private func decodeInt(from data: Data) throws -> Int {
        // Сервер возвращает просто число: 1 или 3
        if let int = try? JSONDecoder().decode(Int.self, from: data) {
            return int
        }
        if let double = try? JSONDecoder().decode(Double.self, from: data) {
            return Int(double)
        }
        throw APIError.decoding(NSError(domain: "ChatService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ожидалось число"]))
    }
}
