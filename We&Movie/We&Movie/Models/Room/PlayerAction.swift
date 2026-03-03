//
//  PlayerAction.swift
//  We&Movie
//

import Foundation

/// Player action: PUT /api/Chat/rooms/{roomId}/player-state, SendPlayerAction
/// action: "play", "pause", "seek", "rate", "changeFilm"
struct PlayerAction: Codable, Sendable {
    let action: String
    let positionSeconds: Double?
    let playbackRate: Float?
    let newFilmToken: Int64?
    let isPaused: Bool?

    static func play() -> PlayerAction {
        PlayerAction(action: "play", positionSeconds: nil, playbackRate: nil, newFilmToken: nil, isPaused: false)
    }

    static func pause() -> PlayerAction {
        PlayerAction(action: "pause", positionSeconds: nil, playbackRate: nil, newFilmToken: nil, isPaused: true)
    }

    static func seek(positionSeconds: Double) -> PlayerAction {
        PlayerAction(action: "seek", positionSeconds: positionSeconds, playbackRate: nil, newFilmToken: nil, isPaused: nil)
    }

    static func rate(_ playbackRate: Float) -> PlayerAction {
        PlayerAction(action: "rate", positionSeconds: nil, playbackRate: playbackRate, newFilmToken: nil, isPaused: nil)
    }

    static func changeFilm(token: Int64) -> PlayerAction {
        PlayerAction(action: "changeFilm", positionSeconds: nil, playbackRate: nil, newFilmToken: token, isPaused: nil)
    }
}
