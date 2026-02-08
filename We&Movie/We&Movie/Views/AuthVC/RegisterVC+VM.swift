//
//  RegisterVC+VM.swift
//  We&Movie
//

import Foundation

extension RegisterVC {
    class VM: BaseVM {
        private let authService: AuthRegisterService

        init(authService: AuthRegisterService = .shared) {
            self.authService = authService
        }

        func register(
            name: String,
            nickname: String?,
            email: String,
            password: String
        ) async throws -> RegisterResponse {
            try await authService.register(
                name: name,
                nickname: nickname,
                email: email,
                password: password
            )
        }
    }
}
