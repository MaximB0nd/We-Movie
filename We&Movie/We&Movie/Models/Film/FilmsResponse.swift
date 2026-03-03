//
//  FilmsResponse.swift
//  We&Movie
//

import Foundation

/// Response: GET /api/FilmCatalog/films
struct FilmsResponse: Codable, Sendable {
    let films: [FilmPreview]
    let totalCount: Int
}
