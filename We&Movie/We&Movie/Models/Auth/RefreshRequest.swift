//
//  RefreshRequest.swift
//  We&Movie
//

import Foundation

/// Запрос обновления токенов: POST /api/auth/refresh
struct RefreshRequest: Codable, Sendable {
    let refreshToken: String
}
