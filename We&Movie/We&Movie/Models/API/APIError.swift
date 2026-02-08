//
//  APIError.swift
//  We&Movie
//

import Foundation

/// Ошибки API по документации
@MainActor
enum APIError: Error, Sendable {
    case invalidURL
    case noData
    case decoding(Error)
    case serverError(String)
    case badRequest(String)
    case unauthorized(String)
    case forbidden(String)
    case notFound(String)
    case conflict(String)
    case unknown(Int, String?)

    /// Сообщение для показа пользователю
    var userMessage: String {
        switch self {
        case .unauthorized(let msg): return msg
        case .forbidden(let msg): return msg
        case .notFound(let msg): return msg
        case .conflict(let msg): return msg
        case .badRequest(let msg): return msg
        case .serverError(let msg): return msg
        case .decoding: return "Ошибка формата ответа"
        case .unknown(_, let msg): return msg ?? "Неизвестная ошибка"
        case .invalidURL, .noData: return "Ошибка сети"
        }
    }
}

/// Ответ с ошибкой от сервера: { "error": "..." }
struct APIErrorResponse: Codable {
    let error: String
}
