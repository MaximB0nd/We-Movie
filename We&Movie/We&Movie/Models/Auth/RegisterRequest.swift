//
//  RegisterRequest.swift
//  We&Movie
//

import Foundation

/// Registration request: POST /api/auth/register
struct RegisterRequest: Codable, Sendable {
    let name: String       // min. 2 characters
    let nickname: String?  // optional
    let email: String      // valid email
    let password: String   // min. 6 characters
}
