//
//  RegisterVC+VM.swift
//  We&Movie
//

import Foundation

extension RegisterVC {
    class VM: BaseVM {
        private let authService: RegisterService
        private let loginService: LoginService

        init(authService: RegisterService = .shared, loginService: LoginService = .shared) {
            self.authService = authService
            self.loginService = loginService
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

        func login(emailOrNickname: String, password: String) async throws -> LoginResponse {
            try await loginService.login(emailOrNickname: emailOrNickname, password: password)
        }
    }
}
