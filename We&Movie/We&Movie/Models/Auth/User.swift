//
//  User.swift
//  We&Movie
//

import Foundation

/// User from API responses (login, refresh, register)
struct User: Codable, Sendable {
    let nickname: String?
    let email: String
}
