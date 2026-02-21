//
//  LoginResponse.swift
//  We&Movie
//

import Foundation

/// Successful login response (200 OK)
struct LoginResponse: Codable, Sendable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int  // seconds until access token expiry
    let user: User
}
