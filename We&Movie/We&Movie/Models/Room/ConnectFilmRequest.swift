//
//  ConnectFilmRequest.swift
//  We&Movie
//

import Foundation

/// Connect film to room: PUT /api/Chat/rooms/{roomId}/connect-film
struct ConnectFilmRequest: Codable, Sendable {
    let token: Int64
}
