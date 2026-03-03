//
//  RoomService.swift
//  We&Movie
//

import Foundation

/// Room service: rooms list, player state, members, moderator.
/// All requests go with Bearer token via APIClient.
final class RoomService: Sendable {

    static let shared = RoomService()
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    // MARK: - Rooms list

    /// Get all rooms for current user.
    func getRooms() async throws -> [Room] {
        let data = try await client.get(path: "api/Chat/chats")
        return try client.decode([Room].self, from: data)
    }

    // MARK: - Create room

    /// Create room. Returns ID of created room.
    func createRoom(name: String, filmToken: Int64 = 0) async throws -> Int {
        let body = CreateRoomRequest(name: name, token: filmToken)
        let data = try await client.post(path: "api/Chat/room", body: body)
        return try decodeInt(from: data)
    }

    // MARK: - Delete room

    /// Delete room. Only host or moderator.
    func deleteRoom(roomId: Int) async throws {
        _ = try await client.delete(path: "api/Chat/\(roomId)")
    }

    // MARK: - Members

    func addMember(roomId: Int, userId: Int) async throws {
        let body = AddRemoveMemberRequest(userId: userId)
        _ = try await client.put(path: "api/Chat/\(roomId)/add-member", body: body)
    }

    func removeMember(roomId: Int, userId: Int) async throws {
        let body = AddRemoveMemberRequest(userId: userId)
        _ = try await client.put(path: "api/Chat/\(roomId)/remove-member", body: body)
    }

    // MARK: - Connect film

    /// Connect film to room. Only host/modifier.
    func connectFilm(roomId: Int, filmToken: Int64) async throws -> ConnectFilmResponse {
        let body = ConnectFilmRequest(token: filmToken)
        let data = try await client.put(path: "api/Chat/rooms/\(roomId)/connect-film", body: body)
        return try client.decode(ConnectFilmResponse.self, from: data)
    }

    // MARK: - Player state

    /// Get current player state in room.
    func getPlayerState(roomId: Int) async throws -> PlayerState {
        let data = try await client.get(path: "api/Chat/rooms/\(roomId)/player-state")
        return try client.decode(PlayerState.self, from: data)
    }

    /// Update player state. Only host/modifier.
    func updatePlayerState(roomId: Int, action: PlayerAction) async throws {
        _ = try await client.put(path: "api/Chat/rooms/\(roomId)/player-state", body: action)
    }

    // MARK: - Moderator

    func grantModerator(roomId: Int, userId: Int) async throws {
        let body = ModeratorActionRequest(userId: userId)
        _ = try await client.put(path: "api/Chat/rooms/\(roomId)/grant-moderator", body: body)
    }

    func revokeModerator(roomId: Int, userId: Int) async throws {
        let body = ModeratorActionRequest(userId: userId)
        _ = try await client.put(path: "api/Chat/rooms/\(roomId)/revoke-moderator", body: body)
    }

    // MARK: - Helpers

    private func decodeInt(from data: Data) throws -> Int {
        if let int = try? JSONDecoder().decode(Int.self, from: data) { return int }
        if let double = try? JSONDecoder().decode(Double.self, from: data) { return Int(double) }
        if let int64 = try? JSONDecoder().decode(Int64.self, from: data) { return Int(int64) }
        throw APIError.decoding(NSError(domain: "RoomService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ожидалось число"]))
    }
}
