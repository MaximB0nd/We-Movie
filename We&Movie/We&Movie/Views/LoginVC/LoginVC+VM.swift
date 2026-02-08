//
//  LoginVC+VM.swift
//  We&Movie
//

import Foundation

extension LoginVC {
    class VM: BaseVM {
        private let authService: LoginService

        init(authService: LoginService = .shared) {
            self.authService = authService
        }

        func login(emailOrNickname: String, password: String) async throws -> LoginResponse {
            try await authService.login(email: emailOrNickname, password: password)
        }
    }
}
