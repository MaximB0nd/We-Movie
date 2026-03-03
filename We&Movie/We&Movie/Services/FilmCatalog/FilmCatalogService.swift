//
//  FilmCatalogService.swift
//  We&Movie
//

import Foundation

/// Film catalog service: list films, get film details.
final class FilmCatalogService: Sendable {

    static let shared = FilmCatalogService()
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    /// Get all films.
    func getFilms() async throws -> FilmsResponse {
        let data = try await client.get(path: "api/FilmCatalog/films")
        return try client.decode(FilmsResponse.self, from: data)
    }

    /// Get film details by token.
    func getFilm(token: Int64) async throws -> FilmDetail {
        let data = try await client.get(path: "api/FilmCatalog/getfilm=\(token)")
        return try client.decode(FilmDetail.self, from: data)
    }
}
