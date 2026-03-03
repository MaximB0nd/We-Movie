//
//  HomeVC+VM.swift
//  We&Movie
//
//  Created by Maxim Bondarev on 16/1/26.
//

import Foundation

@MainActor
extension HomeVC {
    class VM: BaseVM {
        private let filmCatalogService = FilmCatalogService.shared

        private(set) var films: [FilmPreview] = []
        private(set) var isLoading = false
        private(set) var error: Error?

        var onFilmsUpdated: (() -> Void)?
        var onError: ((Error) -> Void)?

        func loadFilms() async {
            guard !isLoading else { return }
            isLoading = true
            error = nil
            onFilmsUpdated?()

            do {
                let response = try await filmCatalogService.getFilms()
                films = response.films
                error = nil
                onFilmsUpdated?()
            } catch let err {
                print(err)
                self.error = err
                onError?(err)
            }

            isLoading = false
            onFilmsUpdated?()
        }
    }
}
