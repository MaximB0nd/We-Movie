//
//  FilmPreview.swift
//  We&Movie
//

import Foundation

/// Film preview in list: GET /api/FilmCatalog/films
struct FilmPreview: Codable, Sendable {
    let token: Int64
    let name: String
    let image: [UInt8]?  // PNG/JPEG bytes, convert to Data/UIImage for display
}
