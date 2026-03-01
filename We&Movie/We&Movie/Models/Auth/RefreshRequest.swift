//
//  RefreshRequest.swift
//  We&Movie
//

import Foundation

/// Token refresh request: POST /api/auth/refresh
struct RefreshRequest: Codable, Sendable {
    let refreshToken: String
}
