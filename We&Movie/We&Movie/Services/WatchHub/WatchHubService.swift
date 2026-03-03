//
//  WatchHubService.swift
//  We&Movie
//
//  Протокол: handshake → Invocation/Completion, сообщения разделены 0x1E.
//

import Foundation

private let recordSeparator = Character(UnicodeScalar(0x1E))

private extension NSLock {
    func withLock<T>(_ body: () -> T) -> T {
        lock()
        defer { unlock() }
        return body()
    }
}

/// Real-time WatchHub: JoinRoom, LeaveRoom, SendPlayerAction, SendRoomMessage.
/// Events: PlayerStateUpdated, MemberJoined, MemberLeft, ReceiveMessage, Error.
final class WatchHubService: @unchecked Sendable {

    static let shared = WatchHubService()
    private let tokenStorage: TokenStorage
    private let baseURL: String
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession?
    private var receiveContinuation: CheckedContinuation<Void, Error>?
    private let receiveLock = NSLock()
    private var pendingCompletions: [String: CheckedContinuation<SignalRCompletion, Error>] = [:]
    private var invocationIdCounter = 0

    // Handlers — вызываются на receive queue
    private var onPlayerStateUpdated: ((PlayerState) async -> Void)?
    private var onMemberJoined: ((RoomEvent) async -> Void)?
    private var onMemberLeft: ((RoomEvent) async -> Void)?
    private var onReceiveMessage: ((ReceiveMessagePayload) async -> Void)?
    private var onError: ((String) async -> Void)?

    init(
        tokenStorage: TokenStorage = .shared,
        baseURL: String = APIConfig.baseURLString
    ) {
        self.tokenStorage = tokenStorage
        self.baseURL = baseURL
    }

    /// Hub URL: ws(s)://<server>/watchHub
    private var hubWebSocketURL: URL? {
        guard let token = tokenStorage.getAccessToken(), !token.isEmpty else { return nil }
        let base = baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let wsScheme = base.hasPrefix("https") ? "wss" : "ws"
        let host = base
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
        let separator = base.contains("?") ? "&" : "?"
        let urlString = "\(wsScheme)://\(host)/watchHub\(separator)access_token=\(token)"
        return URL(string: urlString)
    }

    // MARK: - Connection

    /// Подготовить и запустить соединение. Вызвать on*() до start() для регистрации обработчиков.
    func prepareConnection() throws {
        guard let url = hubWebSocketURL else {
            throw APIError.unauthorized("Нет токена для WatchHub")
        }
        let session = URLSession(configuration: .default)
        let task = session.webSocketTask(with: url)
        self.urlSession = session
        self.webSocketTask = task
    }

    /// Запустить соединение. Вызвать prepareConnection() и on*() перед этим.
    func start() async throws {
        guard let task = webSocketTask else {
            throw APIError.unauthorized("Вызовите prepareConnection() перед start()")
        }
        task.resume()

        // Handshake: {"protocol":"json","version":1}\u001e
        let handshake = "{\"protocol\":\"json\",\"version\":1}\(recordSeparator)"
        try await task.send(.string(handshake))

        // Ждём HandshakeResponse
        let msg = try await task.receive()
        switch msg {
        case .string(let text):
            let parts = text.split(separator: recordSeparator)
            if let first = parts.first, let data = String(first).data(using: .utf8) {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let error = json["error"] as? String, !error.isEmpty {
                    throw APIError.unauthorized(error)
                }
            }
        case .data:
            break
        @unknown default:
            break
        }

        // Запускаем приём сообщений
        Task { [weak self] in
            await self?.receiveLoop()
        }
    }

    /// Остановить соединение.
    func stop() async {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        urlSession = nil
        receiveLock.withLock {
            for (_, cont) in pendingCompletions {
                cont.resume(throwing: APIError.unauthorized("Соединение закрыто"))
            }
            pendingCompletions.removeAll()
        }
    }

    // MARK: - Server methods (invoke)

    func joinRoom(roomId: Int64) async throws {
        try await invoke("JoinRoom", arguments: [roomId])
    }

    func leaveRoom(roomId: Int64) async throws {
        try await invoke("LeaveRoom", arguments: [roomId])
    }

    func sendPlayerAction(roomId: Int64, action: PlayerAction) async throws {
        try await invoke("SendPlayerAction", arguments: [roomId, action])
    }

    func sendRoomMessage(roomId: Int64, text: String) async throws {
        let dto = SendMessageRequest(roomId: roomId, text: text)
        try await invoke("SendChatMessage", arguments: [dto])
    }

    // MARK: - Event handlers (on). Вызвать до start().

    func onPlayerStateUpdated(_ handler: @escaping (PlayerState) async -> Void) {
        onPlayerStateUpdated = handler
    }

    func onMemberJoined(_ handler: @escaping (RoomEvent) async -> Void) {
        onMemberJoined = handler
    }

    func onMemberLeft(_ handler: @escaping (RoomEvent) async -> Void) {
        onMemberLeft = handler
    }

    func onReceiveMessage(_ handler: @escaping (ReceiveMessagePayload) async -> Void) {
        onReceiveMessage = handler
    }

    func onError(_ handler: @escaping (String) async -> Void) {
        onError = handler
    }

    // MARK: - Private: invoke & receive

    private func invoke(_ target: String, arguments: [Any]) async throws {
        guard let task = webSocketTask else { throw APIError.unauthorized("WatchHub не подключён") }

        let id = "\(invocationIdCounter)"
        invocationIdCounter += 1

        let encodedArgs: [Any] = try arguments.map { arg in
            if let p = arg as? PlayerAction {
                let d = try encoder.encode(p)
                return try JSONSerialization.jsonObject(with: d)
            }
            if let s = arg as? SendMessageRequest {
                let d = try encoder.encode(s)
                return try JSONSerialization.jsonObject(with: d)
            }
            return arg
        }

        let payload: [String: Any] = [
            "type": 1,
            "invocationId": id,
            "target": target,
            "arguments": encodedArgs
        ]

        let data = try JSONSerialization.data(withJSONObject: payload)
        guard let json = String(data: data, encoding: .utf8) else { throw APIError.noData }
        let message = "\(json)\(recordSeparator)"

        let messageToSend = message
        let invocationId = id
        let completion = try await withCheckedThrowingContinuation { (cont: CheckedContinuation<SignalRCompletion, Error>) in
            receiveLock.withLock {
                pendingCompletions[invocationId] = cont
            }
            Task { [weak self] in
                do {
                    try await task.send(.string(messageToSend))
                } catch {
                    self?.receiveLock.withLock {
                        if let c = self?.pendingCompletions.removeValue(forKey: invocationId) {
                            c.resume(throwing: error)
                        }
                    }
                }
            }
        }
        if let err = completion.error { throw APIError.unauthorized(err) }
    }

    private func receiveLoop() async {
        guard let task = webSocketTask else { return }
        while true {
            do {
                let msg = try await task.receive()
                switch msg {
                case .string(let text):
                    for part in text.split(separator: recordSeparator) {
                        guard let data = String(part).data(using: .utf8) else { continue }
                        await processMessage(data)
                    }
                case .data(let data):
                    if let str = String(data: data, encoding: .utf8) {
                        for part in str.split(separator: recordSeparator) {
                            guard let d = String(part).data(using: .utf8) else { continue }
                            await processMessage(d)
                        }
                    }
                @unknown default:
                    break
                }
            } catch {
                receiveLock.withLock {
                    for (_, cont) in pendingCompletions {
                        cont.resume(throwing: error)
                    }
                    pendingCompletions.removeAll()
                }
                return
            }
        }
    }

    private func processMessage(_ data: Data) async {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let type = json["type"] as? Int else { return }

        switch type {
        case 1: // Invocation (server → client)
            if let target = json["target"] as? String, let args = json["arguments"] as? [Any] {
                await dispatchInvocation(target: target, arguments: args)
            }
        case 3: // Completion
            if let id = json["invocationId"] as? String {
                let result = json["result"]
                let error = json["error"] as? String
                receiveLock.withLock {
                    if let cont = pendingCompletions.removeValue(forKey: id) {
                        cont.resume(returning: SignalRCompletion(result: result, error: error))
                    }
                }
            }
        case 6: // Ping — игнорируем
            break
        default:
            break
        }
    }

    private func dispatchInvocation(target: String, arguments: [Any]) async {
        switch target {
        case "PlayerStateUpdated":
            if let first = arguments.first,
               let data = try? JSONSerialization.data(withJSONObject: first),
               let state = try? decoder.decode(PlayerState.self, from: data),
               let handler = onPlayerStateUpdated {
                await handler(state)
            }
        case "MemberJoined":
            if let first = arguments.first,
               let data = try? JSONSerialization.data(withJSONObject: first),
               let event = try? decoder.decode(RoomEvent.self, from: data),
               let handler = onMemberJoined {
                await handler(event)
            }
        case "MemberLeft":
            if let first = arguments.first,
               let data = try? JSONSerialization.data(withJSONObject: first),
               let event = try? decoder.decode(RoomEvent.self, from: data),
               let handler = onMemberLeft {
                await handler(event)
            }
        case "ReceiveMessage":
            if let first = arguments.first,
               let data = try? JSONSerialization.data(withJSONObject: first),
               let payload = try? decoder.decode(ReceiveMessagePayload.self, from: data),
               let handler = onReceiveMessage {
                await handler(payload)
            }
        case "Error":
            if let first = arguments.first as? String, let handler = onError {
                await handler(first)
            }
        default:
            break
        }
    }
}

private struct SignalRCompletion {
    let result: Any?
    let error: String?
}
