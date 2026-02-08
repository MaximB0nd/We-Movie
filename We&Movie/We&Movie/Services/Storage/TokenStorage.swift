//
//  TokenStorage.swift
//  We&Movie
//

import Foundation
import Security

/// Безопасное хранение access/refresh токенов в Keychain.
/// Рекомендуется: accessToken — UserDefaults/память, refreshToken — Keychain (документация).
/// Здесь оба в Keychain для единообразия и сохранения при перезапуске.
final class TokenStorage: Sendable {

    static let shared = TokenStorage()

    private let serviceName = "com.wemovie.tokens"
    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"
    private let expiresAtKey = "accessTokenExpiresAt"

    private init() {}

    // MARK: - Access Token

    func getAccessToken() -> String? {
        read(key: accessTokenKey)
    }

    func setAccessToken(_ value: String?) {
        if let value {
            write(key: accessTokenKey, value: value)
        } else {
            delete(key: accessTokenKey)
        }
    }

    // MARK: - Refresh Token

    func getRefreshToken() -> String? {
        read(key: refreshTokenKey)
    }

    func setRefreshToken(_ value: String?) {
        if let value {
            write(key: refreshTokenKey, value: value)
        } else {
            delete(key: refreshTokenKey)
        }
    }

    // MARK: - Expiration (для предобновления за 5–10 мин)

    /// Время истечения access-токена (Date)
    var accessTokenExpiresAt: Date? {
        get {
            guard let str = read(key: expiresAtKey),
                  let interval = TimeInterval(str) else { return nil }
            return Date(timeIntervalSince1970: interval)
        }
        set {
            if let date = newValue {
                write(key: expiresAtKey, value: String(date.timeIntervalSince1970))
            } else {
                delete(key: expiresAtKey)
            }
        }
    }

    /// Нужно ли обновить токен (истёк или скоро истечёт, например за 5 мин)
    var shouldRefreshAccessToken: Bool {
        guard let expiresAt = accessTokenExpiresAt else { return true }
        return Date().addingTimeInterval(5 * 60) >= expiresAt
    }

    /// Есть ли сохранённая сессия (можно ли считать пользователя залогиненным)
    var hasSession: Bool {
        getRefreshToken() != nil
    }

    // MARK: - Clear (logout)

    func clearAll() {
        delete(key: accessTokenKey)
        delete(key: refreshTokenKey)
        delete(key: expiresAtKey)
    }

    // MARK: - Keychain helpers

    private func read(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else { return nil }
        return string
    }

    private func write(key: String, value: String) {
        delete(key: key)
        guard let data = value.data(using: .utf8) else { return }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    private func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
