//
//  RegisterRequest.swift
//  We&Movie
//

import Foundation

/// Запрос регистрации: POST /api/auth/register
struct RegisterRequest: Codable, Sendable {
    let name: String       // мин. 2 символа
    let nickname: String?  // опционально
    let email: String      // валидный email
    let password: String   // мин. 6 символов
}
