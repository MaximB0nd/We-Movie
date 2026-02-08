//
//  LoginResponse.swift
//  We&Movie
//

import Foundation

/// Ответ успешного логина (200 OK)
struct LoginResponse: Codable, Sendable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int  // секунды до истечения access-токена
    let user: User
}
