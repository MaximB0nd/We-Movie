//
//  AuthLoginService.swift
//  We&Movie
//

import Foundation

/// Сервис авторизации: логин, обновление токенов, выход.
final class AuthLoginService: Sendable {

    static let shared = AuthLoginService()
    private let client: APIClient
    private let tokenStorage: TokenStorage

    init(
        client: APIClient = .shared,
        tokenStorage: TokenStorage = .shared
    ) {
        self.client = client
        self.tokenStorage = tokenStorage
    }

    // MARK: - Login

    /// Логин. Сохраняет токены в Keychain и возвращает пользователя + данные для UI.
    func login(email: String, password: String) async throws -> LoginResponse {
        let body = LoginRequest(email: email, password: password)
        let data = try await client.post(path: "api/auth/login", body: body, requireAuth: false)
        let response = try client.decode(LoginResponse.self, from: data)
        saveTokens(from: response)
        return response
    }

    // MARK: - Refresh (вызывается APIClient автоматически при 401, но можно и вручную)

    /// Обновить токены по refreshToken. Обычно не нужен из UI — APIClient делает сам при 401.
    func refresh() async throws -> RefreshResponse {
        guard let refreshToken = tokenStorage.getRefreshToken() else {
            throw APIError.unauthorized("Нет refresh token")
        }
        let body = RefreshRequest(refreshToken: refreshToken)
        let data = try await client.post(path: "api/auth/refresh", body: body, requireAuth: false)
        let response = try client.decode(RefreshResponse.self, from: data)
        saveTokens(from: response)
        return response
    }

    // MARK: - Logout

    /// Выход: удаляет токены. После этого перенаправить на экран логина.
    func logout() {
        tokenStorage.clearAll()
    }

    /// Залогинен ли пользователь (есть refresh token).
    var isLoggedIn: Bool {
        tokenStorage.hasSession
    }

    /// Текущий access token (для отладки или если понадобится в UI).
    var accessToken: String? {
        tokenStorage.getAccessToken()
    }

    // MARK: - Private

    private func saveTokens(from response: LoginResponse) {
        tokenStorage.setAccessToken(response.accessToken)
        tokenStorage.setRefreshToken(response.refreshToken)
        let expiresAt = Date().addingTimeInterval(TimeInterval(response.expiresIn))
        tokenStorage.accessTokenExpiresAt = expiresAt
    }
}
