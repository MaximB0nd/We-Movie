//
//  AuthRegisterService.swift
//  We&Movie
//

import Foundation

/// Registration service: creates new user.
final class RegisterService: Sendable {

    static let shared = RegisterService()
    private let client: APIClient
    private let tokenStorage: TokenStorage

    init(client: APIClient = .shared, tokenStorage: TokenStorage = .shared) {
        self.client = client
        self.tokenStorage = tokenStorage
    }

    /// Registration. Returns tokens and user data on success. Saves tokens to storage.
    func register(
        name: String,
        nickname: String,
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
        let data = try await client.post(path: "api/Auth/register", body: body, requireAuth: false)
        let response = try client.decode(RegisterResponse.self, from: data)
        tokenStorage.setAccessToken(response.accessToken)
        tokenStorage.setRefreshToken(response.refreshToken)
        tokenStorage.accessTokenExpiresAt = Date().addingTimeInterval(TimeInterval(response.expiresIn))
        return response
    }
}
