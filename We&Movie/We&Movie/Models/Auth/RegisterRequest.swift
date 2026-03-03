//
//  RegisterRequest.swift
//  We&Movie
//

import Foundation

/// Registration request: POST /api/Auth/register
struct RegisterRequest: Codable, Sendable {
    let name: String       // min. 2 characters
    let nickname: String   // max 50
    let email: String      // valid email
    let password: String   // min. 6 characters
}
