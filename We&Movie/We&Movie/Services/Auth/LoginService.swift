//
//  AuthLoginService.swift
//  We&Movie
//

import Foundation

/// Auth service: login, token refresh, logout.
final class LoginService: Sendable {

    static let shared = LoginService()
    private let client: APIClient
    private let tokenStorage: TokenStorage
    private let registerService: RegisterService

    init(
        client: APIClient = .shared,
        tokenStorage: TokenStorage = .shared,
        registerService: RegisterService = .shared
    ) {
        self.client = client
        self.tokenStorage = tokenStorage
        self.registerService = registerService
    }

    // MARK: - Login

    /// Login by email or nickname. Saves tokens to Keychain and returns user + UI data.
    func login(emailOrNickname: String, password: String) async throws -> LoginResponse {
        let body: LoginRequest
        if emailOrNickname.contains("@") && emailOrNickname.contains(".") {
            body = LoginRequest(email: emailOrNickname, password: password)
        } else {
            body = LoginRequest(nickname: emailOrNickname, password: password)
        }
        let data = try await client.post(path: "api/auth/login", body: body, requireAuth: false)
        let response = try client.decode(LoginResponse.self, from: data)
        saveTokens(from: response)
        return response
    }

    // MARK: - Refresh (called by APIClient automatically on 401, but can be called manually)

    /// Refresh tokens using refreshToken. Usually not needed from UI — APIClient does it automatically on 401.
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

    /// Validates access token and refreshes if needed.
    /// Returns true if session is valid and can continue.
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

    /// Logout: removes tokens. After this, redirect to login screen.
    func logout() {
        tokenStorage.clearAll()
    }

    /// Whether the user is logged in (has refresh token).
    var isLoggedIn: Bool {
        tokenStorage.hasSession
    }

    /// Current access token (for debugging or if needed in UI).
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
