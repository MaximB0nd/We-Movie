//
//  ConnectFilmResponse.swift
//  We&Movie
//

import Foundation

/// Response from PUT /api/Chat/rooms/{roomId}/connect-film
struct ConnectFilmResponse: Codable, Sendable {
    let filmName: String
    let mediaLink: String
}
