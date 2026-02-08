//
//  RegisterResponse.swift
//  We&Movie
//

import Foundation

/// Ответ успешной регистрации (200 OK)
struct RegisterResponse: Codable, Sendable {
    let nickname: String?
    let email: String
}
