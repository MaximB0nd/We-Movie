//
//  LoginRequest.swift
//  We&Movie
//

import Foundation

/// Запрос логина: POST /api/auth/login
struct LoginRequest: Codable, Sendable {
    let email: String
    let password: String
}
