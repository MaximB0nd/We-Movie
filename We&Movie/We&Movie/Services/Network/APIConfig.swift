//
//  APIConfig.swift
//  We&Movie
//

import Foundation

enum APIConfig {
    /// База URL из документации (будет заменена в prod)
    static let baseURLString = "http://5.39.250.179:5057"
    static var baseURL: URL { URL(string: baseURLString)! }

    /// path: например "api/auth/register" (без ведущего слэша)
    static func url(path: String) -> URL {
        URL(string: path, relativeTo: baseURL)!.absoluteURL
    }
}
