//
//  RegisterVC+VM.swift
//  We&Movie
//

import Foundation

extension RegisterVC {
    class VM: BaseVM {
        private let registerService: RegisterService
        private let loginService: LoginService

        init(
            registerService: RegisterService = .shared,
            loginService: LoginService = .shared
        ) {
            self.registerService = registerService
            self.loginService = loginService
        }

        func registerAndLogin(
            name: String,
            nickname: String?,
            email: String,
            password: String
        ) async throws -> LoginResponse {
            _ = try await registerService.register(
                name: name,
                nickname: nickname,
                email: email,
                password: password
            )
            return try await loginService.login(email: email, password: password)
        }
    }
}
