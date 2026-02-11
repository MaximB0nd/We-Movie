//
//  APIClient.swift
//  We&Movie
//

import Foundation

/// Единая точка сетевых запросов: добавляет Bearer, обрабатывает 401 с refresh и повтором запроса.
final class APIClient: Sendable {

    static let shared = APIClient()
    private let session: URLSession
    private let tokenStorage: TokenStorage
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(
        session: URLSession = .shared,
        tokenStorage: TokenStorage = .shared
    ) {
        self.session = session
        self.tokenStorage = tokenStorage
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }

    // MARK: - Request with optional auth

    /// Выполняет запрос. Если нужен токен — подставляет Bearer. При 401 пробует refresh и повторяет один раз.
    func data(
        for request: URLRequest,
        requireAuth: Bool = true
    ) async throws -> Data {
        var req = addAuthIfNeeded(request, requireAuth: requireAuth)
        var (data, response) = try await session.data(for: req)
        let http = response as? HTTPURLResponse

        if http?.statusCode == 401, requireAuth {
            // Пробуем обновить токены и повторить запрос один раз
            let refreshed = await refreshTokens()
            if refreshed {
                req = addAuthIfNeeded(request, requireAuth: true)
                (data, response) = try await session.data(for: req)
            }
        }

        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw APIError.from(response: http, data: data)
        }
        return data
    }

    /// GET с путём (относительно base). requireAuth: false для register/login/refresh.
    func get(path: String, requireAuth: Bool = true) async throws -> Data {
        var request = URLRequest(url: APIConfig.url(path: path))
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return try await data(for: request, requireAuth: requireAuth)
    }

    /// POST с JSON body
    func post<Body: Encodable>(
        path: String,
        body: Body,
        requireAuth: Bool = true
    ) async throws -> Data {
        var request = URLRequest(url: APIConfig.url(path: path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try encoder.encode(body)
        return try await data(for: request, requireAuth: requireAuth)
    }

    /// POST без body (если понадобится)
    func post(path: String, requireAuth: Bool = true) async throws -> Data {
        var request = URLRequest(url: APIConfig.url(path: path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return try await data(for: request, requireAuth: requireAuth)
    }

    /// PUT с JSON body
    func put<Body: Encodable>(
        path: String,
        body: Body,
        requireAuth: Bool = true
    ) async throws -> Data {
        var request = URLRequest(url: APIConfig.url(path: path))
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try encoder.encode(body)
        return try await data(for: request, requireAuth: requireAuth)
    }

    /// DELETE
    func delete(path: String, requireAuth: Bool = true) async throws -> Data {
        var request = URLRequest(url: APIConfig.url(path: path))
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return try await data(for: request, requireAuth: requireAuth)
    }

    // MARK: - Decode helpers

    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        try decoder.decode(T.self, from: data)
    }

    // MARK: - Private

    private func addAuthIfNeeded(_ request: URLRequest, requireAuth: Bool) -> URLRequest {
        var req = request
        if requireAuth, let token = tokenStorage.getAccessToken(), !token.isEmpty {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return req
    }

    /// Вызывает POST /api/auth/refresh и сохраняет новые токены. Возвращает true при успехе.
    private func refreshTokens() async -> Bool {
        guard let refreshToken = tokenStorage.getRefreshToken(), !refreshToken.isEmpty else {
            return false
        }
        do {
            let body = RefreshRequest(refreshToken: refreshToken)
            let data = try await post(path: "api/auth/refresh", body: body, requireAuth: false)
            let response = try decode(RefreshResponse.self, from: data)
            tokenStorage.setAccessToken(response.accessToken)
            tokenStorage.setRefreshToken(response.refreshToken)
            let expiresAt = Date().addingTimeInterval(TimeInterval(response.expiresIn))
            tokenStorage.accessTokenExpiresAt = expiresAt
            return true
        } catch {
            tokenStorage.clearAll()
            return false
        } 
    }
}

// MARK: - APIError from HTTP response

extension APIError {
    static func from(response: HTTPURLResponse, data: Data) -> APIError {
        let message = parseErrorMessage(from: data)

        switch response.statusCode {
        case 400: return .badRequest(message ?? "Bad Request")
        case 401: return .unauthorized(message ?? "Необходима авторизация")
        case 403: return .forbidden(message ?? "Доступ запрещён")
        case 404: return .notFound(message ?? "Не найдено")
        case 409: return .conflict(message ?? "Конфликт")
        case 500...599: return .serverError(message ?? "Ошибка сервера")
        default: return .unknown(response.statusCode, message)
        }
    }

    private static func parseErrorMessage(from data: Data) -> String? {
        if let decoded = try? JSONDecoder().decode(String.self, from: data), !decoded.isEmpty {
            return decoded
        }
        
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let msg = json["detail"] as? String ?? json["message"] as? String ?? json["error"] as? String {
            return msg
        }
        let raw = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard var s = raw, s.count >= 2 else { return raw }
        if s.first == "\"" && s.last == "\"" {
            s = String(s.dropFirst().dropLast())
        }
        return s.isEmpty ? raw : s
    }
}
