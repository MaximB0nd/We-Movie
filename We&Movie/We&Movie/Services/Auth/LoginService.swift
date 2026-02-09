//
//  AuthLoginService.swift
//  We&Movie
//

import Foundation

/// Сервис авторизации: логин, обновление токенов, выход.
final class LoginService: Sendable {

    static let shared = LoginService()
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
        let email = email.lowercased()
        let body = LoginRequest(email: email, password: password)
        let data = try await client.post(path: "api/auth/login", body: body, requireAuth: false)
        let response = try client.decode(LoginResponse.self, from: data)
        saveTokens(from: response)
        return response
    }

    /// Логин по никнейму. Сохраняет токены в Keychain и возвращает пользователя + данные для UI.
    func login(nickname: String, password: String) async throws -> LoginResponse {
        let body = LoginByNicknameRequest(nickname: nickname, password: password)
        let data = try await client.post(path: "api/auth/login/nickname", body: body, requireAuth: false)
        let response = try client.decode(LoginResponse.self, from: data)
        saveTokens(from: response)
        return response
    }

    /// Моковая регистрация по никнейму и паролю.
    func registerMock(nickname: String, password: String) async throws -> LoginResponse {
        let response = LoginResponse(
            accessToken: UUID().uuidString,
            refreshToken: UUID().uuidString,
            expiresIn: 3600,
            user: User(nickname: nickname, email: "mock@local")
        )
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

    /// Проверяет валидность access-токена и при необходимости обновляет.
    /// Возвращает true, если сессия валидна и можно продолжать.
    func ensureValidSession() async -> Bool {
        guard isLoggedIn else { return false }
        if !tokenStorage.shouldRefreshAccessToken { return true }
        do {
            _ = try await refresh()
            return true
        } catch {
            logout()
            return false
        }
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
