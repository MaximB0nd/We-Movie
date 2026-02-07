//
//  User.swift
//  We&Movie
//

import Foundation

/// Пользователь из ответов API (login, refresh, register)
struct User: Codable, Sendable {
    let nickname: String?
    let email: String
}
