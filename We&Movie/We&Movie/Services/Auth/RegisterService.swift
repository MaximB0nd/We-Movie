//
//  AuthRegisterService.swift
//  We&Movie
//

import Foundation

/// Registration service: creates new user.
final class RegisterService: Sendable {

    static let shared = RegisterService()
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    /// Registration. Returns user data on success.
    func register(
        name: String,
        nickname: String?,
        email: String,
        password: String
    ) async throws -> RegisterResponse {
        let email = email.lowercased()
        let body = RegisterRequest(
            name: name,
            nickname: nickname,
            email: email,
            password: password
        )
        let data = try await client.post(path: "api/auth/register", body: body, requireAuth: false)
        return try client.decode(RegisterResponse.self, from: data)
    }
}
