//
//  LoginByNicknameRequest.swift
//  We&Movie
//

import Foundation

/// Запрос логина по никнейму: POST /api/auth/login/nickname
struct LoginByNicknameRequest: Codable, Sendable {
    let nickname: String
    let password: String
}
