//
//  FilmDetail.swift
//  We&Movie
//

import Foundation

/// Full film info: GET /api/FilmCatalog/getfilm={token}
/// duration — "HH:mm:ss"
struct FilmDetail: Codable, Sendable {
    let token: Int64
    let filmName: String
    let filmDescription: String
    let image: [UInt8]?
    let category: String
    let duration: String  // "02:49:00"
}
