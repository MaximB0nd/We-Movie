//
//  RegisterResponse.swift
//  We&Movie
//

import Foundation

/// Successful registration response (200 OK)
struct RegisterResponse: Codable, Sendable {
    let nickname: String?
    let email: String
}
