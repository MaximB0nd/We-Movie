//
//  LoginRequest.swift
//  We&Movie
//

import Foundation

/// Login request: POST /api/auth/login
/// Either email or nickname must be specified
struct LoginRequest: Codable, Sendable {
    let email: String?
    let nickname: String?
    let password: String

    /// Login by email
    init(email: String, password: String) {
        self.email = email.lowercased()
        self.nickname = nil
        self.password = password
    }

    /// Login by nickname
    init(nickname: String, password: String) {
        self.email = nil
        self.nickname = nickname
        self.password = password
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let email = email { try container.encode(email, forKey: .email) }
        if let nickname = nickname { try container.encode(nickname, forKey: .nickname) }
        try container.encode(password, forKey: .password)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        nickname = try container.decodeIfPresent(String.self, forKey: .nickname)
        password = try container.decode(String.self, forKey: .password)
    }

    private enum CodingKeys: String, CodingKey {
        case email, nickname, password
    }
}
