//
//  APIConfig.swift
//  We&Movie
//

import Foundation

enum APIConfig {
    /// Base URL from docs (will be replaced in prod)
    static let baseURLString = "http://5.39.250.179:5057"
    static var baseURL: URL { URL(string: baseURLString)! }

    /// path: e.g. "api/auth/register" (without leading slash)
    static func url(path: String) -> URL {
        URL(string: path, relativeTo: baseURL)!.absoluteURL
    }
}
