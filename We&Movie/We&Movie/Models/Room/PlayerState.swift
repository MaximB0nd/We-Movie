//
//  PlayerState.swift
//  We&Movie
//

import Foundation

/// Player state: GET /api/Chat/rooms/{roomId}/player-state, PlayerStateUpdated
struct PlayerState: Codable, Sendable {
    let roomId: Int
    let currentFilmId: Int
    let filmName: String
    let mediaLink: String
    let currentPositionSeconds: Double
    let isPaused: Bool
    let playbackRate: Float
    let hostUserId: Int
    let updatedByUserId: Int
    let updatedAt: String  // ISO8601

    enum CodingKeys: String, CodingKey {
        case roomId
        case currentFilmId
        case filmName
        case mediaLink
        case currentPositionSeconds
        case isPaused
        case playbackRate
        case hostUserId
        case updatedByUserId
        case updatedAt
    }
}
